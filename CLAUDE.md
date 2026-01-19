# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains deployment configurations for Polytomic On-Premises, a data integration platform. It provides multiple deployment options across different container platforms including AWS ECS, EKS, GKE, Kubernetes (via Helm), Docker Compose, and Aptible.

## Development Setup

Before contributing, install git hooks:
```bash
git config core.hooksPath hack/hooks
```

The pre-commit hook automatically:
- Formats Terraform code in `terraform/modules/`
- Generates Terraform module documentation using terraform-docs
- Generates Helm chart documentation using helm-docs

## Deployment Methods

### Terraform Deployments

All Terraform commands should be run from the `terraform/` directory or specific example directories.

#### Terraform Development Commands

```bash
# Format all Terraform modules
make format

# Generate/update module documentation (requires terraform-docs)
make generate-docs

# Run security scanning (requires tfsec)
make scan

# Run all checks before committing
make all
```

#### Testing Terraform Changes

1. Make changes to a module in `terraform/modules/<module-name>/`
2. Test using the corresponding minimal example:
   ```bash
   cd terraform/examples/<module>-minimal
   terraform init
   terraform plan
   terraform apply
   ```
3. For targeted resource testing:
   ```bash
   terraform plan -target module.polytomic-ecs.module.s3_bucket
   terraform apply -target module.polytomic-ecs.module.s3_bucket
   ```

### Helm Deployments

#### Helm Development Commands

```bash
# Generate chart documentation (from helm/ directory)
cd helm
helm-docs

# Or for specific chart
cd helm/charts/polytomic
helm-docs
```

#### Installing the Chart

```bash
# Add the repository
helm repo add polytomic https://charts.polytomic.com
helm repo update

# Download values file for customization
curl https://raw.githubusercontent.com/polytomic/on-premises/master/helm/charts/polytomic/values.yaml -o values.yaml

# Install the chart
helm install polytomic polytomic/polytomic -f values.yaml
```

#### Local Kubernetes Testing (KIND)

```bash
./hack/sandbox.sh
```

This script:
- Creates a local KIND cluster
- Sets up NGINX ingress controller
- Prepares the environment for local Helm chart testing

## Architecture

### Terraform Module Structure

**ECS Module** (`terraform/modules/ecs/`):
- Deploys Polytomic on AWS ECS Fargate
- Creates complete infrastructure: ECS services, RDS, Redis, ALB, S3, monitoring
- Key services: web (API), worker, scheduler, sync, schemacache
- Supports existing or new VPC/ECS cluster
- Multi-AZ deployment for high availability

**EKS Module** (`terraform/modules/eks/`):
- Provisions EKS cluster and supporting infrastructure
- Creates VPC, subnets, RDS PostgreSQL, ElastiCache Redis, EFS, S3

**GKE Module** (`terraform/modules/gke/`):
- Similar to EKS but for Google Cloud Platform

**Kubernetes Helm Modules** (`terraform/modules/eks-helm/`, `terraform/modules/gke-helm/`):
- Deploy Polytomic Helm chart on EKS/GKE clusters
- Bridge between Terraform-provisioned infrastructure and Helm deployment

### Helm Chart Structure

Chart location: `helm/charts/polytomic/`

**Key components**:
- **Web deployment**: API service (exposed via ingress)
- **Worker deployment**: Background job processing
- **Sync deployment**: Data synchronization service
- **Dev deployment**: Development/debugging service (disabled by default)
- **Dependencies**: PostgreSQL, Redis, NFS provisioner (all optional)

**Configuration**:
- `values.yaml`: Main configuration file with all deployment options
- `templates/`: Kubernetes manifests with Go templating
- Authentication: Supports Google OAuth, WorkOS SSO, or single-player mode
- Storage: S3 for logs/exports, EFS/NFS for shared cache

## Common Development Tasks

### Updating Terraform Module Versions

1. Modify version in module source reference
2. Run `terraform init -upgrade` in examples directory
3. Test with `terraform plan`
4. Update documentation with `make generate-docs`

### Adding New Terraform Variables

1. Add variable to `vars.tf` in the module
2. Add corresponding usage in module resources
3. Update examples to demonstrate usage
4. Run `make generate-docs` to update README

### Modifying ECS Task Definitions

Task definitions are in `terraform/modules/ecs/task-definitions/*.json.tftpl`:
- Use Terraform templating for dynamic values
- Key interpolations: `${local.image}`, `${local.environment}`, CPU/memory settings
- After changes, test with targeted apply to task definition resource

### Updating Helm Chart Values

1. Modify `helm/charts/polytomic/values.yaml`
2. Update template files in `helm/charts/polytomic/templates/` if needed
3. Run `helm-docs` to regenerate README
4. Test locally using KIND cluster or specific K8s environment

### Version Releases

Releases are tracked in `CHANGELOG.md`. When creating a new release:
1. Update `CHANGELOG.md` with version number and changes
2. Tag the release in git
3. Follow semantic versioning for Terraform modules and Helm charts

## Important Configuration Notes

### Container Image

Default image repository: `568237466542.dkr.ecr.us-west-2.amazonaws.com/polytomic-onprem`

Always specify a concrete version tag (e.g., `rel2021.11.04`) rather than `latest` for production deployments. Available versions: https://docs.polytomic.com/changelog

### Authentication Methods

- **Google OAuth**: Requires client ID/secret, authorized origins, redirect URIs
- **WorkOS SSO**: Requires API key, client ID, organization ID
- **Single-player mode**: No authentication (for development only)

### Required Environment Variables

Core variables across all deployment methods:
- `DEPLOYMENT`: Unique identifier provided by Polytomic
- `DEPLOYMENT_KEY`: License key provided by Polytomic
- `DATABASE_URL` or separate DB connection parameters
- `REDIS_URL` or separate Redis connection parameters
- `POLYTOMIC_URL`: Base URL for the deployment
- `ROOT_USER`: Initial admin user email

## Testing and Validation

### Terraform

- Use `terraform plan` before apply
- Test in minimal examples first
- Run `tfsec` for security scanning

### Helm

- Use `helm lint` before installing
- Test with `helm template` to preview rendered manifests
- Install with `--dry-run` flag first

## Documentation Standards

- Terraform module documentation is auto-generated from code comments using terraform-docs
- Helm chart documentation is auto-generated from values.yaml using helm-docs
- Do not manually edit README.md files in `terraform/modules/` or `helm/charts/` - they will be overwritten

## Security Considerations

- Never commit credentials or secrets to version control
- Use AWS Secrets Manager, Kubernetes Secrets, or similar for sensitive data
- Enable encryption at rest for databases and caches
- Use TLS/SSL for all external communications
- Review security group rules and network policies
