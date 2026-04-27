# Changelog - GKE Helm Deployment Module

All notable changes to the GKE Helm deployment module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **MCP server support**: Variables to enable and configure the Polytomic MCP server deployment, matching the support added to the ECS module in chart v1.4.0.
  - `polytomic_mcp_enabled` (default: `false`): Enables the MCP server deployment.
  - `polytomic_mcp_image` (default: `polytomic-mcp`): Image name for the MCP server.
  - `polytomic_mcp_image_tag` (default: inherits `polytomic_image_tag`): Tag for the MCP image.
  - `polytomic_mcp_replica_count` (default: `1`): Number of MCP replicas.
  - `polytomic_mcp_api_version` (default: `2025-09-18`): Polytomic API version for MCP.
  - `polytomic_mcp_ingress_enabled` (default: `false`): Expose MCP via a separate GKE ingress.
  - `polytomic_mcp_url`, `polytomic_mcp_cert_name`, `polytomic_mcp_ip_name`: Hostname, GCP managed SSL cert, and global static IP for the MCP ingress.

## [1.2.0] - 2026-04-07

This release brings the GKE Helm module in sync with the EKS Helm module (v1.2.0),
adding Vector DaemonSet and Datadog Agent support.

### Added

- **Vector DaemonSet log collection**: When `polytomic_use_logger = true` (the default), a Vector DaemonSet is deployed to collect stdout/stderr container logs. Uses Workload Identity for GCS write access.
- **`image_registry` variable**: Separate container registry from image name (e.g., `us.gcr.io/polytomic-container-distro`), matching the Helm chart's `imageRegistry` value.
- **`polytomic_use_logger` variable** (default: `true`): Deploys the Vector DaemonSet for log collection.
- **`polytomic_logger_image` variable** (default: `polytomic-vector`): Image name for the Vector DaemonSet.
- **`polytomic_logger_image_tag` variable** (default: inherits `polytomic_image_tag`): Tag for the Vector DaemonSet image.
- **`polytomic_logger_service_account` variable**: GCP service account email for Vector DaemonSet Workload Identity. Defaults to `polytomic_service_account` when unset.
- **`polytomic_managed_logs` variable** (default: `false`): Enables Datadog log forwarding.
- **Datadog Agent DaemonSet**: `polytomic_use_dd_agent`, `polytomic_dd_agent_image`, `polytomic_dd_agent_image_tag` variables for APM tracing.
- **`database_name` / `database_username` variables**: Propagate custom database settings to the Helm release (default: `polytomic`).
- **`extra_helm_values` variable**: Merges additional YAML values after module defaults.
- **`force_update` variable**: Force Helm release updates.
- **`wait` / `timeout` variables**: Configurable wait behavior for Helm releases.
- `versions.tf` with Helm provider version constraint.
- NFS server provisioner enabled by default with `nfs` storageClass and 25Gi backing volume.

### Changed

- `polytomic_image` is now just the image name (without registry prefix); combined with `image_registry` to form the full reference.
- `dependency_update` on Helm release only enabled when using a remote chart repository (fixes offline local chart installs).
- Vector DaemonSet service account falls back to `polytomic_service_account` when `polytomic_logger_service_account` is not set.
- Updated for compatibility with Helm chart v1.3.x
- Removed deprecated configuration fields (record_log_bucket)
- Sensitive variables (`polytomic_deployment_key`, `postgres_password`, `polytomic_google_client_secret`) now marked as `sensitive`
- NFS dynamic provisioner uses explicit `nfs` storageClassName

## [1.0.0] - 2023-01-30

This is the initial versioned release of the GKE Helm deployment module, establishing a baseline for future releases.

### Added

- Initial GKE Helm Terraform module
