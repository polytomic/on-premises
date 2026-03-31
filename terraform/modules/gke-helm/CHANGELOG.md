# Changelog - GKE Helm Deployment Module

All notable changes to the GKE Helm deployment module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-03-31

This release brings the GKE Helm module in sync with the EKS Helm module (v1.2.0),
adding Vector DaemonSet and Datadog Agent support.

### Added

- **Vector DaemonSet log collection**: When `polytomic_use_logger = true` (the default), a Vector DaemonSet is deployed to collect stdout/stderr container logs. Uses Workload Identity for GCS write access.
- **`polytomic_use_logger` variable** (default: `true`): Deploys the Vector DaemonSet for log collection.
- **`polytomic_logger_image` variable** (default: `polytomic-vector`): Image name for the Vector DaemonSet.
- **`polytomic_logger_image_tag` variable** (default: inherits `polytomic_image_tag`): Tag for the Vector DaemonSet image.
- **`polytomic_logger_service_account` variable**: GCP service account email for Vector DaemonSet Workload Identity, granting GCS write access.
- **`polytomic_managed_logs` variable** (default: `false`): Enables Datadog log forwarding.
- **Datadog Agent DaemonSet**: `polytomic_use_dd_agent`, `polytomic_dd_agent_image`, `polytomic_dd_agent_image_tag` variables for APM tracing.
- **`extra_helm_values` variable**: Merges additional YAML values after module defaults.
- **`force_update` variable**: Force Helm release updates.
- **`wait` / `timeout` variables**: Configurable wait behavior for Helm releases.
- **`dependency_update = true`** on Helm release for automatic chart dependency resolution.
- `versions.tf` with Helm provider version constraint.

### Changed

- Updated for compatibility with Helm chart v1.3.x
- Removed deprecated configuration fields (record_log_bucket)
- Sensitive variables (`polytomic_deployment_key`, `postgres_password`, `polytomic_google_client_secret`) now marked as `sensitive`

## [1.0.0] - 2023-01-30

This is the initial versioned release of the GKE Helm deployment module, establishing a baseline for future releases.

### Added

- Initial GKE Helm Terraform module
