# Polytomic On-Premises Changelog

This repository contains multiple deployment components, each with its own changelog.

## Component Changelogs

### Helm Chart

See [helm/charts/polytomic/CHANGELOG.md](helm/charts/polytomic/CHANGELOG.md)

- **Current Version**: 1.2.0
- **Latest Tag**: `polytomic-1.2.0`

### Terraform Modules

#### ECS Module

See [terraform/modules/ecs/CHANGELOG.md](terraform/modules/ecs/CHANGELOG.md)

- **Current Version**: 2.7.0
- **Latest Tag**: `terraform/ecs/v2.7.0`

#### EKS Infrastructure Module

See [terraform/modules/eks/CHANGELOG.md](terraform/modules/eks/CHANGELOG.md)

- **Current Version**: 1.0.0
- **Latest Tag**: `terraform/eks/v1.0.0`

#### EKS Addons Module

See [terraform/modules/eks-addons/CHANGELOG.md](terraform/modules/eks-addons/CHANGELOG.md)

- **Current Version**: 1.0.0
- **Latest Tag**: `terraform/eks-addons/v1.0.0`

#### EKS Helm Deployment Module

See [terraform/modules/eks-helm/CHANGELOG.md](terraform/modules/eks-helm/CHANGELOG.md)

- **Current Version**: 1.2.0
- **Latest Tag**: `terraform/eks-helm/v1.2.0`

#### GKE Infrastructure Module

See [terraform/modules/gke/CHANGELOG.md](terraform/modules/gke/CHANGELOG.md)

- **Current Version**: 1.0.0
- **Latest Tag**: `terraform/gke/v1.0.0`

#### GKE Helm Deployment Module

See [terraform/modules/gke-helm/CHANGELOG.md](terraform/modules/gke-helm/CHANGELOG.md)

- **Current Version**: 1.0.0
- **Latest Tag**: `terraform/gke-helm/v1.0.0`

## Versioning Strategy

As of January 2026, this repository uses a structured monorepo versioning approach with component-specific tags. See [VERSIONING.md](VERSIONING.md) for details on our versioning and release process.

### Legacy Tags

Prior to January 2026:

- `polytomic-0.0.x` tags referred to Helm chart releases
- `v1.x.x` and `v2.x.x` tags referred to ECS module releases
- Some components had no tagged releases

All components now follow the structured tagging format described in VERSIONING.md.
