# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## Module Overview

This is a Terraform module that deploys Polytomic (a data integration platform)
on AWS ECS Fargate. It creates a complete infrastructure including ECS services,
RDS database, Redis cache, ALB, S3 buckets, and monitoring.

## Development Commands

Run these from the root terraform directory (`/terraform`):

```bash
# Format all module code
make format

# Generate/update module documentation
make generate-docs

# Run security scanning
make scan

# Run all checks before committing
make all
```

## Testing Workflow

1. Make changes to module code in `modules/ecs/`
2. Test using the minimal example:
   ```bash
   cd examples/ecs-minimal
   terraform init
   terraform plan
   terraform apply
   ```
3. For testing specific resources:
   ```bash
   terraform plan -target module.polytomic-ecs.module.s3_bucket
   terraform apply -target module.polytomic-ecs.module.s3_bucket
   ```

## Module Architecture

### Core Components

- **ECS Services**: web (API), worker, scheduler, sync, schemacache
- **Task Definitions**: Located in `task-definitions/*.json.tftpl` - templated JSON files
- **Infrastructure Files**:
  - `vpc.tf` - Network configuration
  - `ecs-cluster.tf` & `ecs-tasks.tf` - Container orchestration
  - `alb.tf` - Load balancer
  - `database.tf` - RDS PostgreSQL
  - `redis.tf` - ElastiCache
  - `efs.tf` - Shared file storage
  - `buckets.tf` - S3 for exports/artifacts

### Key Design Patterns

- Can use existing VPC/ECS cluster OR create new ones (controlled by `create_vpc`/`create_ecs_cluster` variables)
- All services support optional sidecars (Vector for logging, Datadog for monitoring)
- Multi-AZ deployment for high availability
- Comprehensive tagging strategy using `var.tags`

### Module Dependencies

This module uses community modules from terraform-aws-modules for standardized AWS resource creation. Key dependencies:

- VPC, ECS, RDS, S3, Security Groups, CloudWatch modules
- Provider version constraints: AWS >= 4.0, < 6.0.0

## Common Tasks

### Adding a New Service

1. Create task definition in `task-definitions/`
2. Add ECS service configuration in `ecs-tasks.tf`
3. Update security groups if needed
4. Add any service-specific resources

### Updating Task Definitions

Task definitions use `.json.tftpl` templates with variable substitution. Key variables:

- `local.image` - Container image
- `local.environment` - Environment variables
- CPU/memory settings from variables

### Debugging

- CloudWatch logs in `/aws/ecs/${var.prefix}/${service_name}`
- Check ECS service events in AWS Console
- Use `terraform state` commands to inspect resources
