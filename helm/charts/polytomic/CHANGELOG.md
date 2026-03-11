# Changelog - Polytomic Helm Chart

All notable changes to the Polytomic Helm chart will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.4] - 2026-03-11

### Added

- **External secret support for PostgreSQL and Redis passwords**: New `externalPostgresql.existingSecret` and `externalRedis.existingSecret` values allow referencing pre-existing Kubernetes Secrets for database and Redis passwords instead of storing them in Helm values. When configured, passwords are injected via `secretKeyRef` environment variables and interpolated into connection URLs at runtime using `${DATABASE_PASSWORD}` and `${REDIS_PASSWORD}` placeholders.

- **Secret propagation to executor pods**: `KUBERNETES_SECRET_ENV` and `KUBERNETES_EXTRA_SECRETS` environment variables are now automatically set so that dynamically created executor (sync/bulk) pods receive the same secret-backed credentials as the main deployments.

### Fixed

- **Database/Redis password env vars only injected when needed**: `DATABASE_PASSWORD` and `REDIS_PASSWORD` environment variables from `secretKeyRef` are now conditionally injected only when an `existingSecret` is configured, rather than being unconditionally present on all deployments.

### Changed

- Improved documentation for `externalPostgresql.existingSecret` and `externalRedis.existingSecret` values in `values.yaml`.

| Value                                       | Default                | Description                                              |
| ------------------------------------------- | ---------------------- | -------------------------------------------------------- |
| `externalPostgresql.existingSecret.name`    | `""`                   | Name of existing K8s secret for database password        |
| `externalPostgresql.existingSecret.key`     | `"postgresql-password"` | Key within the secret containing the password           |
| `externalRedis.existingSecret.name`         | `""`                   | Name of existing K8s secret for Redis password           |
| `externalRedis.existingSecret.key`          | `"redis-password"`     | Key within the secret containing the password            |

---

## [1.3.3] - 2026-03-09

### Added

- **Datadog container metrics collection**: New `polytomic.datadog.daemonset.containerMetrics` toggle (default: `true`) enables CPU and memory metrics via kubelet. Adds host volume mounts for `/proc` and `/sys/fs/cgroup`.

- **Datadog process agent**: New `polytomic.datadog.daemonset.processAgent` toggle (default: `true`) enables live container monitoring in Datadog.

- **Datadog container filtering**: New `polytomic.datadog.daemonset.includeContainers` and `excludeContainers` values for scoping metrics collection. Defaults to the release namespace. Supports `kube_namespace:`, `image:`, `name:`, and `kube_label:` prefixes.

- **Polytomic executor pod label tagging**: Datadog agent now maps `polytomic.com/type`, `polytomic.com/sync-id`, and `polytomic.com/execution-id` pod labels as Datadog tags for executor pod metrics.

- **Task executor resource defaults**: The `polytomic.roles.task` base role now ships with non-zero defaults: `cpu: 1000` (1000m request), `memory_reservation: 2048` (2Gi request), `memory_maximum: 8192` (8Gi limit), `memory_mega: 8192` (8Gi mega request). Previously all values were 0, leaving executor pods unconstrained.

### Changed

- Bumped Datadog agent memory limit default from 512Mi to 768Mi to accommodate process agent and metrics collection overhead.

| Value                                              | Default    | Description                                        |
| -------------------------------------------------- | ---------- | -------------------------------------------------- |
| `polytomic.datadog.daemonset.containerMetrics.enabled` | `true`  | Enable CPU/memory metrics via kubelet              |
| `polytomic.datadog.daemonset.processAgent.enabled`     | `true`  | Enable live container monitoring                   |
| `polytomic.datadog.daemonset.includeContainers`        | `""`    | Container include filter (default: release namespace) |
| `polytomic.datadog.daemonset.excludeContainers`        | `""`    | Container exclude filter                           |

---

## [1.3.2] - 2026-03-05

### Fixed

- **Log duplication when using Vector DaemonSet**: When the DaemonSet is enabled, the app now writes structured JSON directly to stdout instead of routing through the embedded Vector's unix socket. This eliminates duplicate logs in Datadog caused by the embedded Vector's debug console sink echoing logs back to stdout. Requires app image with `VECTOR_DAEMONSET` support.

### Changed

- **Renamed `polytomic.internal_execution_logs` to `polytomic.embeddedVector.enabled`**: Clarifies that this setting controls the in-pod embedded Vector process for non-DaemonSet deployments (e.g. ECS). When `vector.daemonset.enabled=true` (the default), this is not required.

- **`VECTOR_DAEMONSET` env var**: Automatically set to `true` when `vector.daemonset.enabled=true`. Tells the app to bypass the embedded Vector unix socket and write to stdout for DaemonSet collection.

### Migration

If you previously set `polytomic.internal_execution_logs: true` for DaemonSet log collection, remove it and ensure `vector.daemonset.enabled: true` (the default). The DaemonSet now handles everything automatically.

For non-DaemonSet deployments (ECS), replace:
```yaml
polytomic:
  internal_execution_logs: true
```
with:
```yaml
polytomic:
  embeddedVector:
    enabled: true
```

---

## [1.3.1] - 2026-03-05

### Added

- **Extra environment variables for secret**: New `polytomic.extraEnv` map allows injecting arbitrary key-value pairs into the chart-generated Kubernetes Secret without modifying the chart.

- **External secrets support**: New `extraSecrets` list allows mounting additional pre-existing Kubernetes Secrets as environment variables. Secrets are appended after the main secret in `envFrom`, so their values take precedence. Secrets must exist in the same namespace as the Helm release.

- **Datadog DaemonSet scheduling options**: New `polytomic.datadog.daemonset.nodeSelector` and `polytomic.datadog.daemonset.affinity` values allow scheduling Datadog Agent DaemonSet pods on specific nodes, complementing the existing `tolerations` option.

| Value                                       | Default | Description                                              |
| ------------------------------------------- | ------- | -------------------------------------------------------- |
| `polytomic.extraEnv`                        | `{}`    | Arbitrary env vars added to the Polytomic secret         |
| `extraSecrets`                              | `[]`    | List of existing Secrets to mount (e.g. `- name: foo`)   |
| `polytomic.datadog.daemonset.nodeSelector`  | `{}`    | Node selector for Datadog DaemonSet pods                 |
| `polytomic.datadog.daemonset.affinity`      | `{}`    | Affinity rules for Datadog DaemonSet pods                |

---

## [1.3.0] - 2026-03-02

### Added

- **Datadog Agent DaemonSet (optional)**: New `polytomic.datadog.daemonset.*` values deploy a Datadog Agent DaemonSet plus ServiceAccount, ClusterRole, and ClusterRoleBinding for APM/metrics collection.

### Changed

- **APM env wiring when Datadog is enabled**: When `polytomic.datadog.daemonset.enabled=true`, all Polytomic pods now receive `DD_AGENT_HOST` (set to the Datadog Service name), and `METRICS` is forced on to ensure metrics emission.

---

## [1.2.1] - 2026-02-20

### Added

- **Kubernetes task executor scheduling options**: New `polytomic.kubernetes.nodeSelectors` and `polytomic.kubernetes.tolerations` values allow scheduling dynamically created task executor pods on specific nodes. These are passed to the application as `KUBERNETES_NODE_SELECTORS` and `KUBERNETES_TOLERATIONS` environment variables.

- **Vector DaemonSet scheduling options**: New `polytomic.vector.daemonset.nodeSelector` and `polytomic.vector.daemonset.affinity` values allow scheduling Vector DaemonSet pods on specific nodes, complementing the existing `tolerations` option.

| Value                                    | Default | Description                                                |
| ---------------------------------------- | ------- | ---------------------------------------------------------- |
| `polytomic.kubernetes.nodeSelectors`     | `""`    | Node selectors for task pods (format: `key=value,key=value`) |
| `polytomic.kubernetes.tolerations`       | `""`    | Tolerations for task pods (format: `key:operator:value:effect`) |
| `polytomic.vector.daemonset.nodeSelector`| `{}`    | Node selector for Vector DaemonSet pods                    |
| `polytomic.vector.daemonset.affinity`    | `{}`    | Affinity rules for Vector DaemonSet pods                   |

---

## [1.2.0] - 2026-02-19

### Added

- **Vector DaemonSet for log collection**: A Vector DaemonSet is now deployed by
  default to collect stdout/stderr container logs from all Polytomic pods on
  each node. Logs are filtered by the `vector.dev/include=true` label, which is
  automatically applied to all Polytomic pod templates. When
  `polytomic.vector.managedLogs` is enabled, logs are forwarded to Datadog. This
  matches ECS deployment behavior where `polytomic_use_logger` defaults to
  `true`.

- **`imageRegistry` value**: A new top-level `imageRegistry` value controls the
  ECR registry prefix (e.g. `568237466542.dkr.ecr.us-west-2.amazonaws.com`)
  separately from the image name. Defaults to the us-west-2 ECR registry.
  Override to use a different AWS region without needing to change each image's
  repository path.

- **`image.tag` is now required**: `image.tag` must be set explicitly. It no
  longer falls back to `Chart.appVersion`.

### Changed

- `image.repository` now contains only the image name (`polytomic-onprem`)
  rather than the full ECR URL. The registry prefix is now controlled by
  `imageRegistry`.

### Upgrade Notes

**`image.repository` format change (action required):** If you have set
`image.repository` to a full ECR URL (e.g.
`568237466542.dkr.ecr.us-west-2.amazonaws.com/polytomic-onprem`), you must split
it into two values:

```yaml
imageRegistry: "568237466542.dkr.ecr.us-west-2.amazonaws.com"
image:
  repository: polytomic-onprem
```

Leaving the old full URL in `image.repository` will result in an incorrectly
constructed image reference.

**Vector DaemonSet is enabled by default.** The DaemonSet requires elevated
privileges (root) to read container log files from the host node. To disable it:

```yaml
polytomic:
  vector:
    daemonset:
      enabled: false
```

**New `polytomic.vector` values:**

| Value                                               | Default                     | Description                                   |
| --------------------------------------------------- | --------------------------- | --------------------------------------------- |
| `polytomic.vector.daemonset.enabled`                | `true`                      | Deploy the Vector DaemonSet                   |
| `polytomic.vector.daemonset.image`                  | `polytomic-vector`          | Image name (registry set via `imageRegistry`) |
| `polytomic.vector.daemonset.tag`                    | `""` (inherits `image.tag`) | Image tag override                            |
| `polytomic.vector.daemonset.tolerations`            | `[]`                        | Additional tolerations for Vector pods        |
| `polytomic.vector.daemonset.serviceAccount.roleArn` | `""`                        | IAM role ARN for IRSA (EKS)                   |
| `polytomic.vector.managedLogs`                      | `false`                     | Forward logs to Datadog                       |

---

## [1.0.2] - 2026-01-21

**BREAKING CHANGES**: This is a major modernization of the Helm chart with several breaking changes.

### Changed

- **BREAKING**: Split roles into dedicated pods for better resource management
- **BREAKING**: Bumped minimum Kubernetes version to 1.34.0
- **BREAKING**: Removed deprecated PostgreSQL and Redis configuration options
- **BREAKING**: Removed deprecated `polytomic.cache` configuration
- **BREAKING**: Removed deprecated S3 bucket configuration fields
- Bumped dependency chart versions (PostgreSQL 18.2.3, Redis 24.1.2)
- Updated image pull secret configuration to use curly-brace substitution

### Removed

- Vestigial `record_log_bucket` configuration

## Previous Releases (0.0.x series)

The following releases used the `polytomic-0.0.x` tag format.

### [0.0.17] - 2024-05-01

- Maintenance release

### [0.0.16] - 2024-02-08

- Add support for v2 execution logging in Kubernetes deployments

### [0.0.15] - 2024-01-08

- Maintenance release

### [0.0.14] - 2023-11-30

- Maintenance release

### [0.0.13] - 2023-08-11

- Maintenance release

### [0.0.12] - 2023-08-08

- Add separate `schemacache` role deployment

### [0.0.11] - 2023-07-28

- Expose annotations via downward API volume mount

### [0.0.10] - 2023-07-19

- Maintenance release

### [0.0.9] - 2023-07-14

- Allow overriding configuration secret

### [0.0.8] - 2023-07-14

- Allow adding sidecar containers to deployments

### [0.0.7] - 2023-07-12

- Maintenance release

### [0.0.6] - 2023-06-19

- Maintenance release

### [0.0.5] - 2023-02-02

- Chart updates for EKS module support

### [0.0.4] - 2023-01-30

- Initial versioned release
- Chart updates for GKE module support
