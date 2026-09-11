#!/usr/bin/env bash
#
# Rendering tests for the Prometheus metrics endpoint in the polytomic chart.
#
# `ct lint` proves the chart renders without error; this proves it renders the
# right thing. Every assertion below is a behaviour an on-premises operator
# depends on, and several fail silently if they regress: a scrape annotation
# pointing at the wrong port, a ServiceMonitor whose selector stops matching its
# Service, or an upgrade with --reuse-values that aborts because a release
# installed before these values existed has none of them.
#
# Usage: hack/test-prometheus-render.sh
# Requires: helm, python3 with PyYAML. Touches no cluster.

set -euo pipefail

CHART="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/helm/charts/polytomic"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

failures=0
pass() { printf '  ok    %s\n' "$1"; }
fail() { printf '  FAIL  %s\n' "$1"; failures=$((failures + 1)); }

check() { # check <description> <condition-exit-code>
  if [ "$2" -eq 0 ]; then pass "$1"; else fail "$1"; fi
}

render() { # render <output-file> [helm args...]
  local out="$1"; shift
  helm template polytomic "$CHART" --set image.tag=render-test "$@" >"$out"
}

# query <file> <python-expression-returning-bool>
# Parses the rendered manifests so assertions are about structure, not about
# text that happens to appear somewhere in a 2000-line document.
query() {
  python3 - "$1" <<PYEOF
import sys, yaml
docs = [d for d in yaml.safe_load_all(open(sys.argv[1])) if d]
def kind(k, name=None):
    return [d for d in docs
            if d.get("kind") == k
            and (name is None or d["metadata"]["name"] == name)]
def scheduler():
    return kind("Deployment", "polytomic-scheduler")[0]["spec"]["template"]
def addr():
    env = scheduler()["spec"]["containers"][0].get("env") or []
    return [e["value"] for e in env if e["name"] == "PROMETHEUS_METRICS_ADDR"]
def scrape_annotations():
    ann = scheduler()["metadata"].get("annotations") or {}
    return {k: v for k, v in ann.items() if k.startswith("prometheus.io/")}
$2
PYEOF
}

echo "== disabled by default =="
render "$TMP/off.yaml"
check "no metrics Service" \
  "$(query "$TMP/off.yaml" 'sys.exit(0 if not kind("Service","polytomic-metrics") else 1)'; echo $?)"
check "no ServiceMonitor" \
  "$(query "$TMP/off.yaml" 'sys.exit(0 if not kind("ServiceMonitor") else 1)'; echo $?)"
check "no PROMETHEUS_METRICS_ADDR anywhere" \
  "$(query "$TMP/off.yaml" '
sec = kind("Secret", "polytomic-config")[0]["stringData"]
sys.exit(0 if "PROMETHEUS_METRICS_ADDR" not in sec and not addr() else 1)'; echo $?)"
check "scheduler has no metrics port and no scrape annotations" \
  "$(query "$TMP/off.yaml" '
ports = scheduler()["spec"]["containers"][0].get("ports") or []
sys.exit(0 if not ports and not scrape_annotations() else 1)'; echo $?)"

echo "== enabled =="
render "$TMP/on.yaml" --set polytomic.prometheus.enabled=true \
  --set scheduler.podAnnotations."example\.com/owner"=platform-team
check "the scheduler container carries the listen address" \
  "$(query "$TMP/on.yaml" 'sys.exit(0 if addr() == [":9090"] else 1)'; echo $?)"
# The shared config Secret is mounted by every role, so a variable placed there
# changes all seven pod template checksums, and enabling the endpoint would roll
# the whole data plane, sync pods included. Keeping it off the Secret is what
# makes enabling metrics restart only the scheduler.
check "the listen address stays out of the shared config secret" \
  "$(query "$TMP/on.yaml" '
sys.exit(0 if "PROMETHEUS_METRICS_ADDR" not in kind("Secret","polytomic-config")[0]["stringData"] else 1)'; echo $?)"
check "scheduler exposes a named metrics container port" \
  "$(query "$TMP/on.yaml" '
c = scheduler()["spec"]["containers"][0]
sys.exit(0 if c["ports"] == [{"name":"metrics","containerPort":9090,"protocol":"TCP"}] else 1)'; echo $?)"
# Annotation discovery and a ServiceMonitor are separate scrape jobs, so turning
# both on scrapes the endpoint twice. Each is opt-in for that reason.
check "no scrape annotations without scrapeAnnotations" \
  "$(query "$TMP/on.yaml" 'sys.exit(0 if not scrape_annotations() else 1)'; echo $?)"
check "operator-supplied pod annotations survive" \
  "$(query "$TMP/on.yaml" '
a = scheduler()["metadata"]["annotations"]
sys.exit(0 if a.get("example.com/owner") == "platform-team" else 1)'; echo $?)"
check "metrics Service targets the scheduler on the named port" \
  "$(query "$TMP/on.yaml" '
s = kind("Service", "polytomic-metrics")[0]
sys.exit(0 if s["spec"]["type"] == "ClusterIP"
         and s["spec"]["selector"]["app.kubernetes.io/name"] == "polytomic-scheduler"
         and s["spec"]["ports"] == [{"port":9090,"targetPort":"metrics","protocol":"TCP","name":"metrics"}]
         else 1)'; echo $?)"
check "the scheduler it selects is still a single replica" \
  "$(query "$TMP/on.yaml" '
sys.exit(0 if kind("Deployment","polytomic-scheduler")[0]["spec"]["replicas"] == 1 else 1)'; echo $?)"
check "no ServiceMonitor without its own flag" \
  "$(query "$TMP/on.yaml" 'sys.exit(0 if not kind("ServiceMonitor") else 1)'; echo $?)"

echo "== scrape annotations =="
render "$TMP/ann.yaml" --set polytomic.prometheus.enabled=true \
  --set polytomic.prometheus.scrapeAnnotations=true
check "annotations point at the metrics port and /metrics" \
  "$(query "$TMP/ann.yaml" '
sys.exit(0 if scrape_annotations() == {"prometheus.io/scrape": "true",
                                       "prometheus.io/port": "9090",
                                       "prometheus.io/path": "/metrics"} else 1)'; echo $?)"
render "$TMP/ann-off.yaml" --set polytomic.prometheus.scrapeAnnotations=true
check "scrapeAnnotations alone adds nothing while the endpoint is disabled" \
  "$(query "$TMP/ann-off.yaml" 'sys.exit(0 if not scrape_annotations() else 1)'; echo $?)"

echo "== a custom port propagates to every surface =="
render "$TMP/port.yaml" --set polytomic.prometheus.enabled=true \
  --set polytomic.prometheus.scrapeAnnotations=true --set polytomic.prometheus.port=9464
check "env, container port, annotation, and Service all agree on 9464" \
  "$(query "$TMP/port.yaml" '
tpl = scheduler()
svc = kind("Service","polytomic-metrics")[0]["spec"]["ports"][0]["port"]
sys.exit(0 if addr() == [":9464"]
         and tpl["spec"]["containers"][0]["ports"][0]["containerPort"] == 9464
         and scrape_annotations()["prometheus.io/port"] == "9464"
         and svc == 9464 else 1)'; echo $?)"

echo "== enabling metrics does not restart the data plane =="
# A changed pod template checksum means a rolling restart. Enabling an
# observability endpoint must not restart web, sync, or worker pods; a sync pod
# restarted here is an interrupted execution. The scheduler's own template does
# change, which is correct and is the only restart this feature should cause.
checksums() { # checksums <file> -> "name=sum" per deployment
  query "$1" '
for d in kind("Deployment"):
    a = d["spec"]["template"]["metadata"].get("annotations") or {}
    print(d["metadata"]["name"] + "=" + str(a.get("checksum/config")))'
}
if diff <(checksums "$TMP/off.yaml" | grep -v "^polytomic-scheduler=") \
        <(checksums "$TMP/on.yaml"  | grep -v "^polytomic-scheduler=") >/dev/null; then
  pass "no other deployment's pod template checksum changes"
else
  fail "no other deployment's pod template checksum changes"
  diff <(checksums "$TMP/off.yaml") <(checksums "$TMP/on.yaml") | sed 's/^/        /'
fi

echo "== ServiceMonitor =="
render "$TMP/sm-default.yaml" --set polytomic.prometheus.enabled=true \
  --set polytomic.prometheus.serviceMonitor.enabled=true
check "defaults to a 60s interval and 10s timeout" \
  "$(query "$TMP/sm-default.yaml" '
ep = kind("ServiceMonitor","polytomic-metrics")[0]["spec"]["endpoints"][0]
sys.exit(0 if ep["interval"] == "60s" and ep["scrapeTimeout"] == "10s" else 1)'; echo $?)"

render "$TMP/sm.yaml" --set polytomic.prometheus.enabled=true \
  --set polytomic.prometheus.serviceMonitor.enabled=true \
  --set polytomic.prometheus.serviceMonitor.labels.release=kube-prometheus \
  --set polytomic.prometheus.serviceMonitor.interval=15s \
  --set polytomic.prometheus.serviceMonitor.scrapeTimeout=5s \
  --set 'polytomic.prometheus.serviceMonitor.metricRelabelings[0].action=labeldrop' \
  --set 'polytomic.prometheus.serviceMonitor.metricRelabelings[0].regex=organization_id'
check "carries the configured labels, timings, and relabelings" \
  "$(query "$TMP/sm.yaml" '
m = kind("ServiceMonitor","polytomic-metrics")[0]
ep = m["spec"]["endpoints"][0]
sys.exit(0 if m["metadata"]["labels"].get("release") == "kube-prometheus"
         and ep["interval"] == "15s" and ep["scrapeTimeout"] == "5s"
         and ep["port"] == "metrics" and ep["path"] == "/metrics"
         and ep["metricRelabelings"] == [{"action":"labeldrop","regex":"organization_id"}]
         else 1)'; echo $?)"
# The selector and the Service labels are written in two different files, so
# nothing but an assertion keeps them in agreement.
check "its selector actually matches the metrics Service labels" \
  "$(query "$TMP/sm.yaml" '
sel = kind("ServiceMonitor","polytomic-metrics")[0]["spec"]["selector"]["matchLabels"]
lab = kind("Service","polytomic-metrics")[0]["metadata"]["labels"]
sys.exit(0 if all(lab.get(k) == v for k, v in sel.items()) else 1)'; echo $?)"
# helm.sh/chart carries the chart version, so a selector including it would
# stop matching the Service after the next upgrade.
check "its selector does not include the chart version label" \
  "$(query "$TMP/sm.yaml" '
sel = kind("ServiceMonitor","polytomic-metrics")[0]["spec"]["selector"]["matchLabels"]
sys.exit(0 if "helm.sh/chart" not in sel else 1)'; echo $?)"
check "it selects only the metrics Service" \
  "$(query "$TMP/sm.yaml" '
sel = kind("ServiceMonitor","polytomic-metrics")[0]["spec"]["selector"]["matchLabels"]
hits = [s["metadata"]["name"] for s in kind("Service")
        if all((s["metadata"].get("labels") or {}).get(k) == v for k, v in sel.items())]
sys.exit(0 if hits == ["polytomic-metrics"] else 1)'; echo $?)"

echo "== NetworkPolicy =="
render "$TMP/np-off.yaml" --set networkPolicy.enabled=true
render "$TMP/np-on.yaml" --set networkPolicy.enabled=true --set polytomic.prometheus.enabled=true
check "enabling the endpoint leaves the NetworkPolicy unchanged" \
  "$(python3 - "$TMP/np-off.yaml" "$TMP/np-on.yaml" <<'PYEOF'
import sys, yaml
def policies(path):
    return [d for d in yaml.safe_load_all(open(path)) if d and d.get("kind") == "NetworkPolicy"]
sys.exit(0 if policies(sys.argv[1]) == policies(sys.argv[2]) else 1)
PYEOF
echo $?)"

echo "== upgrading with --reuse-values =="
# --reuse-values replaces the new chart's defaults with the values recorded for
# the previous release. A release installed before polytomic.prometheus existed
# has none of it, and an operator who then enables the endpoint supplies only
# the one key. Setting a default to null removes it, which reproduces both.
if render "$TMP/reuse.yaml" --set polytomic.prometheus=null 2>"$TMP/reuse.err"; then
  pass "renders with polytomic.prometheus absent"
  check "and renders no metrics objects" \
    "$(query "$TMP/reuse.yaml" '
sys.exit(0 if not kind("Service","polytomic-metrics") and not kind("ServiceMonitor") and not addr() else 1)'; echo $?)"
else
  fail "renders with polytomic.prometheus absent"
  sed 's/^/        /' "$TMP/reuse.err"
fi
if render "$TMP/reuse-on.yaml" --set polytomic.prometheus.port=null \
     --set polytomic.prometheus.scrapeAnnotations=null \
     --set polytomic.prometheus.serviceMonitor=null \
     --set polytomic.prometheus.enabled=true 2>"$TMP/reuse-on.err"; then
  pass "renders with only polytomic.prometheus.enabled set"
  check "and falls back to port 9090 with no ServiceMonitor or annotations" \
    "$(query "$TMP/reuse-on.yaml" '
svc = kind("Service","polytomic-metrics")[0]["spec"]["ports"][0]["port"]
sys.exit(0 if addr() == [":9090"] and svc == 9090
         and not kind("ServiceMonitor") and not scrape_annotations() else 1)'; echo $?)"
else
  fail "renders with only polytomic.prometheus.enabled set"
  sed 's/^/        /' "$TMP/reuse-on.err"
fi

echo "== install notes =="
# The endpoint is not on the Polytomic URL, so the notes are where an operator
# learns the address to scrape. helm template does not render NOTES.txt, so
# these go through a client-side dry-run install, which touches no cluster.
notes() { # notes <output-file> [helm args...]
  local out="$1"; shift
  helm install polytomic "$CHART" --dry-run=client --namespace metrics-ns \
    --set image.tag=render-test "$@" >"$out" 2>&1
}
has() { grep -qF -- "$2" "$1"; echo $?; }
lacks() { if grep -qF -- "$2" "$1"; then echo 1; else echo 0; fi; }

notes "$TMP/notes-off.txt"
check "no metrics section while the endpoint is disabled" \
  "$(lacks "$TMP/notes-off.txt" "PROMETHEUS METRICS")"

# fullnameOverride renames the Service, so this proves the printed address
# follows the Service rather than assuming "polytomic-metrics".
notes "$TMP/notes-on.txt" --set polytomic.prometheus.enabled=true \
  --set polytomic.prometheus.port=9464 --set fullnameOverride=acme
render "$TMP/notes-on.yaml" --set polytomic.prometheus.enabled=true \
  --set fullnameOverride=acme
check "prints the in-cluster address of the metrics Service" \
  "$(has "$TMP/notes-on.txt" "http://acme-metrics.metrics-ns.svc:9464/metrics")"
check "which is the name the Service is created with" \
  "$(query "$TMP/notes-on.yaml" 'sys.exit(0 if kind("Service","acme-metrics") else 1)'; echo $?)"
check "points at a static scrape config when no discovery is enabled" \
  "$(has "$TMP/notes-on.txt" "Discovery: none configured")"

notes "$TMP/notes-sm.txt" --set polytomic.prometheus.enabled=true \
  --set polytomic.prometheus.serviceMonitor.enabled=true
check "warns when the ServiceMonitor has no labels" \
  "$(has "$TMP/notes-sm.txt" "serviceMonitor.labels is empty")"
notes "$TMP/notes-sm-labels.txt" --set polytomic.prometheus.enabled=true \
  --set polytomic.prometheus.serviceMonitor.enabled=true \
  --set polytomic.prometheus.serviceMonitor.labels.release=kube-prometheus
check "and stops warning once labels are set" \
  "$(lacks "$TMP/notes-sm-labels.txt" "WARNING")"
notes "$TMP/notes-both.txt" --set polytomic.prometheus.enabled=true \
  --set polytomic.prometheus.serviceMonitor.enabled=true \
  --set polytomic.prometheus.serviceMonitor.labels.release=kube-prometheus \
  --set polytomic.prometheus.scrapeAnnotations=true
check "warns when two discovery modes would scrape it twice" \
  "$(has "$TMP/notes-both.txt" "both enabled")"

notes "$TMP/notes-reuse.txt" --set polytomic.prometheus=null
check "render with polytomic.prometheus absent" \
  "$(has "$TMP/notes-reuse.txt" "GETTING STARTED")"
notes "$TMP/notes-reuse-on.txt" --set polytomic.prometheus.port=null \
  --set polytomic.prometheus.scrapeAnnotations=null \
  --set polytomic.prometheus.serviceMonitor=null \
  --set polytomic.prometheus.enabled=true
check "and print the default port with only enabled set" \
  "$(has "$TMP/notes-reuse-on.txt" "http://polytomic-metrics.metrics-ns.svc:9090/metrics")"

echo
if [ "$failures" -ne 0 ]; then
  echo "$failures assertion(s) failed"
  exit 1
fi
echo "all assertions passed"
