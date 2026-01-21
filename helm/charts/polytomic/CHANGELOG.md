# Changelog - Polytomic Helm Chart

All notable changes to the Polytomic Helm chart will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - Unreleased

**BREAKING CHANGES**: This is a major modernization of the Helm chart with several breaking changes.

**Note**: This version is currently in the `eks-module-versions` branch and has not yet been merged to master.

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
