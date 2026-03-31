# Changelog - GKE Infrastructure Module

All notable changes to the GKE infrastructure module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-03-31

This release brings the GKE module in sync with the EKS module (v1.1.0), upgrading all
upstream module dependencies and adding configurability for cluster, database, and cache.

### Added

- `versions.tf` with pinned provider versions (Google `>= 6.0, < 8.0.0`, Terraform `>= 1.5.7`)
- `prefix` variable for resource naming (default: "polytomic")
- `labels` variable for applying labels to all resources
- GKE node pool configuration variables: `instance_type`, `min_size`, `max_size`, `desired_size`
- Database configurability: `database_name`, `database_username`, `database_version`, `database_deletion_protection`, `database_backup_retention`, `database_availability_type`, `database_maintenance_window_day`, `database_maintenance_window_hour`, `database_disk_size`, `database_disk_autoresize`, `database_disk_autoresize_limit`
- Redis configurability: `redis_version`, `redis_auth_enabled`, `redis_transit_encryption_mode`, `redis_maintenance_window_day`, `redis_maintenance_window_hour`
- `network_name` and `network_id` outputs
- Smart bucket name defaulting (`{prefix}-operations` when `bucket_name` is empty)
- Conditional guard on `workload_identity_sa` IAM binding

### Changed

- Default PostgreSQL version upgraded from POSTGRES_14 to POSTGRES_17
- Default instance tier changed from `db-f1-micro` to `db-custom-2-7680` (production-suitable)
- Default `database_deletion_protection` set to `true` (was `false`)
- Upgraded `terraform-google-modules/kubernetes-engine` from `24.1.0` to `~> 35.0`
- Upgraded `terraform-google-modules/network` from `6.0.0` to `~> 12.0`
- Upgraded `terraform-google-modules/memorystore` from `7.0.0` to `~> 12.0`
- Upgraded `GoogleCloudPlatform/sql-db` from `13.0.1` to `~> 23.0`
- All outputs now have conditional guards (safe when `create_redis`/`create_postgres` is false)
- `postgres_password` output marked as `sensitive`
- Resource names use `prefix` variable instead of hardcoded "polytomic"
- Memorystore module uses `project_id` parameter (renamed from `project` in upstream v12)

### Fixed

- Outputs no longer fail when `create_redis = false` or `create_postgres = false`

## [1.0.0] - 2023-08-01

This is the initial versioned release of the GKE infrastructure module, establishing a baseline for future releases.

### Previous Changes (unversioned)

- 2023-08-01: Add GCS bucket resource to GKE Terraform module
- 2023-07-11: Add support for GCS record logs
- 2023-01-30: Initial GKE Terraform module
