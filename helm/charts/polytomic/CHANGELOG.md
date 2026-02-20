# Changelog - Polytomic Helm Chart

All notable changes to the Polytomic Helm chart will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
