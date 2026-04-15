# Changelog - EKS Infrastructure Module

All notable changes to the EKS infrastructure module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-01-21

This release adds support for EKS addons, improved IAM configurations, and comprehensive installation documentation.

### Added

- Comprehensive installation documentation (INSTALL.md with 800+ lines of deployment guidance)
- Support for EKS managed addons (aws-ebs-csi-driver, aws-efs-csi-driver)
- IAM roles for EBS CSI driver with IRSA integration
- IAM roles for EFS CSI driver with IRSA integration
- Support for EKS access entries configuration via `access_entries` variable
- IAM policy attachment for ECR image pulls on node groups
- Provider version constraints in versions.tf for stability

### Changed

- Updated Kubernetes version to 1.34
- Increased default instance type from t3.small to t3.medium
- Improved S3 bucket name handling with better defaults
- Updated VPC module to version ~> 6.0
- Updated EKS module to version ~> 21.0
- Updated IAM module to version ~> 5.0 for CSI driver roles

### Fixed

- Removed vestigial record_log_bucket configuration

## [1.0.0] - 2024-11-20

This is the initial versioned release of the EKS infrastructure module, establishing a baseline for future releases.

### Changed

- Remove hard-coded tracing, profiling from tasks

### Previous Changes (unversioned)

- 2024-04-30: Update RDS CA cert bundle
- 2024-02-06: Upgrade default database engine version
- 2023-08-11: Updates to EKS Helm Terraform module
- 2023-02-02: Initial EKS Terraform module
