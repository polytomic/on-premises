# Changelog - EKS Helm Deployment Module

All notable changes to the EKS Helm deployment module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Vector DaemonSet log collection**: When `polytomic_use_logger = true` (the default), a Vector DaemonSet is deployed alongside Polytomic pods to collect stdout/stderr container logs. This matches the behavior of the ECS module's `polytomic_use_logger` variable.

- **IAM role for Vector DaemonSet (IRSA)**: When `polytomic_use_logger = true` and `oidc_provider_arn` is provided, the module automatically creates an IAM role (`<deployment>-vector-daemonset`) and policy (`<deployment>-vector-s3`) granting `s3:PutObject` on the execution log bucket. The role is bound to the `polytomic:polytomic-vector` Kubernetes service account via IRSA.

- **`ecr_registry` variable**: Controls the ECR registry base URL for all Polytomic images. Defaults to `568237466542.dkr.ecr.us-west-2.amazonaws.com`. Override to use a different AWS region.

- **`polytomic_use_logger` variable** (default: `true`): Deploys the Vector DaemonSet for log collection. Set to `false` to disable in dev environments or when using an alternative log collector. Matches the ECS module variable.

- **`polytomic_managed_logs` variable** (default: `false`): Enables Datadog log forwarding for both the embedded Vector process and the DaemonSet. Matches the ECS module variable.

- **`polytomic_logger_image` variable** (default: `polytomic-vector`): Image name for the Vector DaemonSet.

- **`polytomic_logger_image_tag` variable** (default: inherits `polytomic_image_tag`): Tag for the Vector DaemonSet image. Override to pin the logger to a different tag than the main application.

- **`oidc_provider_arn` variable**: EKS OIDC provider ARN required for IRSA. When provided alongside `polytomic_use_logger = true`, the IAM role and policy for the Vector DaemonSet are created automatically.

- **`execution_log_bucket_arn` variable**: ARN of the S3 bucket for execution logs. When provided, scopes the Vector IAM policy to this specific bucket. Falls back to `polytomic_bucket` when not set.

### Changed

- `polytomic_image` now has a default value of `polytomic-onprem` and an explicit `type = string`. Previously it had no default and no type annotation.

### Upgrade Notes

**Vector DaemonSet is enabled by default** (`polytomic_use_logger = true`). If you are not yet ready to adopt DaemonSet-based log collection, set:

```hcl
polytomic_use_logger = false
```

**To enable full log collection with S3 write access**, provide your cluster's OIDC provider ARN:

```hcl
module "polytomic_helm" {
  source = "..."

  oidc_provider_arn        = module.eks.oidc_provider_arn
  execution_log_bucket_arn = aws_s3_bucket.logs.arn
  polytomic_use_logger     = true
  polytomic_managed_logs   = true  # set to true to also forward to Datadog
}
```

---

## [1.1.0] - 2026-01-21

### Changed

- Updated for compatibility with Helm chart v1.0.0
- Removed deprecated configuration fields
- Make Helm chart version configurable

## [1.0.0] - 2023-08-11

This is the initial versioned release of the EKS Helm deployment module, establishing a baseline for future releases.

### Previous Changes (unversioned)

- Initial EKS Helm Terraform module
