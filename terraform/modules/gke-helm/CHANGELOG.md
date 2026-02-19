# Changelog - GKE Helm Deployment Module

All notable changes to the GKE Helm deployment module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Updated for compatibility with Helm chart v1.0.0
- Removed deprecated configuration fields (record_log_bucket)

### Notes

- **Vector DaemonSet support not yet implemented**: The EKS Helm module now supports Vector DaemonSet-based log collection with automatic IAM role configuration (IRSA). The GKE Helm module does not yet have equivalent support for Workload Identity and GCS permissions. This functionality gap will be addressed in a future release.

## [1.0.0] - 2023-01-30

This is the initial versioned release of the GKE Helm deployment module, establishing a baseline for future releases.

### Added

- Initial GKE Helm Terraform module
