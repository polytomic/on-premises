# Deploying Polytomic on GCP / GKE

This guide covers running the Polytomic Helm chart on Google Kubernetes Engine,
with execution logs stored in Google Cloud Storage (GCS) and authentication via
Workload Identity. It assumes you have already read the chart `README.md` and
have a working install in mind.

> If you are on **GKE Autopilot**, also review the `1.6.0` and `1.7.0` entries in
> `charts/polytomic/CHANGELOG.md`: Autopilot requires
> `polytomic.vector.daemonset.dataDir.type: emptyDir` (its admission controller
> blocks write-mode `hostPath`) and per-role `ephemeral_storage_*` settings.

## How logging works

Polytomic emits structured execution logs to **stdout**. A **Vector DaemonSet**
runs one pod per node, collects those lines from `/var/log/pods`, and ships them
to the operational bucket. The app then **reads** them back out of the bucket to
display and export logs in the UI.

```
app pods ──stdout──► Vector DaemonSet ──writes──► gs://<bucket>
                                                          │
   UI  ◄────────────── app reads/signs/exports ◄──────────┘
```

Two distinct identities touch the bucket, and **both** need write access on GCP:

| Identity (KSA)        | Used by                                           | Bucket access it needs                              |
| --------------------- | ------------------------------------------------- | --------------------------------------------------- |
| App ServiceAccount    | web, worker, sync, scheduler, … and executor jobs | read + write + delete (`roles/storage.objectAdmin`) |
| Vector ServiceAccount | the Vector DaemonSet only                         | write-only (`roles/storage.objectCreator`)          |

The app reads, lists, signs, and deletes objects (serving logs in the UI,
building exports, garbage-collecting), so it needs full object access. **Vector
only ever creates new objects**, so object-create is sufficient.

Grant these roles at the **bucket** level, as shown below. Do not scope IAM
policy — or any external tooling — to specific object prefixes: the internal
key layout is an implementation detail that changes between releases.

## Required values

```yaml
polytomic:
  s3:
    gcs: true                          # select the GCS sinks in the Vector config
    operational_bucket: "gs://my-operational-bucket"
  vector:
    daemonset:
      enabled: true
      dataDir:
        type: emptyDir                 # required on GKE Autopilot
```

`operational_bucket` is the same bucket the app uses; `gcs: true` switches the
Vector ConfigMap from the S3 sinks to the `gcp_cloud_storage` sinks.

## Workload Identity setup

On GCP there is **no credential env var** wired for the GCS sinks — Vector and the
app both authenticate implicitly via Workload Identity. Each Kubernetes
ServiceAccount (KSA) must be annotated to impersonate a Google ServiceAccount
(GSA), and the GSA must be granted on the bucket.

Set these once:

```bash
PROJECT=<your-project>
NAMESPACE=<release-namespace>          # e.g. polytomic
RELEASE=<helm-release-name>            # e.g. polytomic-prod
BUCKET=<bucket-name>                   # no gs:// prefix
```

### App ServiceAccount

The app KSA is `polytomic.serviceAccountName` — `<release>` by default, or
whatever you set in `serviceAccount.name`.

```bash
APP_GSA=polytomic-app
APP_KSA=$RELEASE                       # or your serviceAccount.name

gcloud iam service-accounts create "$APP_GSA" --project="$PROJECT"

gsutil iam ch \
  "serviceAccount:${APP_GSA}@${PROJECT}.iam.gserviceaccount.com:roles/storage.objectAdmin" \
  "gs://${BUCKET}"

gcloud iam service-accounts add-iam-policy-binding \
  "${APP_GSA}@${PROJECT}.iam.gserviceaccount.com" --project="$PROJECT" \
  --role="roles/iam.workloadIdentityUser" \
  --member="serviceAccount:${PROJECT}.svc.id.goog[${NAMESPACE}/${APP_KSA}]"
```

```yaml
serviceAccount:
  create: true
  annotations:
    iam.gke.io/gcp-service-account: "polytomic-app@<project>.iam.gserviceaccount.com"
```

> If you manage the app ServiceAccount yourself (`serviceAccount.create: false`,
> `serviceAccount.name: <existing>`), annotate that existing SA out-of-band
> instead — the chart will not template annotations onto an SA it does not create.

### Vector ServiceAccount

Vector uses its **own** ServiceAccount, separate from the app. As of chart
**1.8.0** you have three options:

**Option A — dedicated, write-only GSA (recommended).** Vector is the highest-risk
pod (runs as root, mounts the host `/var/log`, reads every pod's logs), so give it
the narrowest possible identity:

```bash
VEC_GSA=polytomic-vector-logs
VEC_KSA=${RELEASE}-vector              # chart-created name

gcloud iam service-accounts create "$VEC_GSA" --project="$PROJECT" \
  --display-name="Polytomic Vector log writer (write-only)"

gsutil iam ch \
  "serviceAccount:${VEC_GSA}@${PROJECT}.iam.gserviceaccount.com:roles/storage.objectCreator" \
  "gs://${BUCKET}"

gcloud iam service-accounts add-iam-policy-binding \
  "${VEC_GSA}@${PROJECT}.iam.gserviceaccount.com" --project="$PROJECT" \
  --role="roles/iam.workloadIdentityUser" \
  --member="serviceAccount:${PROJECT}.svc.id.goog[${NAMESPACE}/${VEC_KSA}]"
```

```yaml
polytomic:
  vector:
    daemonset:
      serviceAccount:
        create: true
        annotations:
          iam.gke.io/gcp-service-account: "polytomic-vector-logs@<project>.iam.gserviceaccount.com"
```

**Option B — share an existing ServiceAccount.** If you already run all app pods
under one Workload Identity SA and want Vector to reuse it, bind Vector to that SA
by name. The chart points the daemonset **and** Vector's ClusterRoleBinding at the
named SA, so it still receives the pod-log read permission Vector needs.

```bash
# Add the Vector KSA as a second authorized member of the existing GSA
gcloud iam service-accounts add-iam-policy-binding \
  "<existing-gsa>@${PROJECT}.iam.gserviceaccount.com" --project="$PROJECT" \
  --role="roles/iam.workloadIdentityUser" \
  --member="serviceAccount:${PROJECT}.svc.id.goog[${NAMESPACE}/<existing-ksa>]"
```

```yaml
polytomic:
  vector:
    daemonset:
      serviceAccount:
        create: false
        name: <existing-ksa>           # e.g. the SA your app pods use
```

Sharing is simpler but over-privileges the daemonset if the shared GSA has roles
beyond the operational bucket (KMS, Secret Manager, other buckets, …). Prefer
Option A unless the shared GSA is itself scoped to just this bucket.

**Option C — chart-created with the default name.** Omit `create`/`name` (defaults
to `create: true`, name `<release>-vector`) and annotate as in Option A. This is
the historical behavior.

## Verify

```bash
# Annotations present on both SAs
kubectl get sa "$RELEASE" -n "$NAMESPACE" -o jsonpath='{.metadata.annotations}'
kubectl get sa "${RELEASE}-vector" -n "$NAMESPACE" -o jsonpath='{.metadata.annotations}'

# From inside a Vector pod, the metadata server should return the bound GSA email
POD=$(kubectl get pod -n "$NAMESPACE" -l app.kubernetes.io/name=polytomic-vector -o name | head -1)
kubectl exec -n "$NAMESPACE" "$POD" -- wget -qO- \
  --header="Metadata-Flavor: Google" \
  "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/email"

# Vector logs should be free of auth errors
kubectl logs -n "$NAMESPACE" "$POD" | grep -E '403|implicit GCP token|dns error' || echo clean
```

## Troubleshooting

**`ERROR ... 403 Forbidden` / `Not retriable; dropping the request` on a GCS sink.**
Vector obtained a token but the identity it resolved to lacks
`storage.objects.create` on the bucket. Causes, in order of likelihood:

- The Vector KSA is not annotated with `iam.gke.io/gcp-service-account` (it fell
  back to a default node identity). → annotate it (Options A–C above).
- The GSA has no role on the bucket. → `gsutil iam ch …objectCreator gs://BUCKET`.
- The Workload Identity member string is wrong. It is case-sensitive and exact:
  `PROJECT.svc.id.goog[NAMESPACE/KSA]`. A typo here produces exactly this 403.

**`ERROR ... Failed to get implicit GCP token: ... dns error: ... Try again`,
followed by Vector restarting.** Vector cannot reach the metadata server
(`metadata.google.internal`) to mint a token, so the sink fails to build and the
pod crash-loops. Usually a symptom of the same broken Workload Identity path
(transient during the crash-loop). Confirm Workload Identity is enabled on the
node pool — on Autopilot it is by default; on Standard the node pool needs
`--workload-metadata=GKE_METADATA`. Re-check after fixing the annotation/binding;
bindings can take a minute or two to propagate.

**The bucket has objects but the UI shows no execution logs.** The app and Vector
use separate identities, so one can be healthy while the other is not. The app
writes its own objects (exports, changeset data, probes) and reads everything
back; Vector is the only writer of execution logs. So objects in the bucket
confirm the app SA works, but say nothing about Vector — diagnose Vector
independently via its pod logs and the metadata-server check above rather than by
inspecting bucket contents.
