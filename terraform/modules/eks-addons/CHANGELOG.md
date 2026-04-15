# Changelog - EKS Addons Module

All notable changes to the EKS addons module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-04-15

### Added

- **Cluster Autoscaler** (opt-in): New `enable_cluster_autoscaler` variable deploys the Kubernetes Cluster Autoscaler via Helm for EKS node group scaling (#134).

### Fixed

- Shortened resource names to stay within AWS length limits when the deployment prefix is long.

## [1.1.0] - 2026-01-21

### Changed

- Pinned provider versions for stability

## [1.0.0] - 2023-02-02

This is the initial versioned release of the EKS addons module, establishing a baseline for future releases.
