# Polytomic EKS Complete Example

This example demonstrates a complete production-ready Polytomic deployment on AWS EKS with external managed services (RDS PostgreSQL, ElastiCache Redis, EFS).

## Architecture

This example creates:

- **EKS Cluster** with managed node groups
- **VPC** with public/private subnets across 3 availability zones
- **RDS PostgreSQL** Multi-AZ database
- **ElastiCache Redis** cluster
- **EFS** filesystem for shared storage
- **S3 Bucket** for Polytomic operations and logs
- **AWS Load Balancer Controller** for ingress
- **EFS CSI Driver** for volume mounting
- **Polytomic Application** deployed via Helm chart with production configuration

## Deployment Stages

This example has two stages that must be applied in order:

1. **cluster** - Creates EKS cluster and infrastructure (VPC, RDS, Redis, EFS, S3)
2. **app** - Installs Kubernetes add-ons and deploys Polytomic

## Prerequisites

- AWS CLI configured with credentials
- Terraform v1.0+
- kubectl installed
- Helm installed
- Route53 hosted zone for your domain
- Polytomic license (deployment name and key)
- Google OAuth credentials (client ID and secret)

## Quick Start

### Step 1: Deploy Infrastructure (cluster)

```bash
cd cluster

# Edit main.tf and update the locals block:
# - region: Your AWS region
# - prefix: Resource name prefix (used for all resources)
# - vpc_azs: Availability zones
# - bucket_name: (Optional) Explicit S3 bucket name. Defaults to "${prefix}-operational"

terraform init
terraform plan
terraform apply
```

**Time**: 15-20 minutes

### Step 2: Deploy Application (app)

```bash
cd ../app

# Edit main.tf and update the locals block:
# - url: Your domain name (e.g., polytomic.example.com)
# - domain: Route53 hosted zone (e.g., example.com)
# - polytomic_deployment: Provided by Polytomic team
# - polytomic_deployment_key: Provided by Polytomic team
# - polytomic_api_key: Optional API key
# - polytomic_image_tag: Use specific version (not "latest" for production)
# - polytomic_root_user: Your admin email
# - polytomic_google_client_id: Google OAuth client ID
# - polytomic_google_client_secret: Google OAuth secret

terraform init
terraform plan
terraform apply
```

**Time**: 5-10 minutes

### Step 3: Access the Deployment

```bash
# Configure kubectl
aws eks update-kubeconfig --region us-west-2 --name polytomic-cluster

# Check deployment status
kubectl get pods -n polytomic

# Get ALB DNS name
kubectl get ingress -n polytomic
```

The ingress will show the ALB hostname. The ACM certificate validation and Route53 records are handled automatically by Terraform.

Navigate to `https://your-domain.com` to access Polytomic.

## Configuration Details

### Cluster Stage (cluster/main.tf)

Key configuration:

```hcl
locals {
  region  = "us-west-2"           # AWS region
  prefix  = "polytomic"           # Resource name prefix (used for cluster, DB, etc.)
  vpc_azs = ["us-west-2a", ...]   # Availability zones

  # Optional: Uncomment to override default bucket name
  # bucket_name = "my-company-polytomic-prod"  # Must be globally unique
}
```

Creates:

- EKS 1.24 cluster with t3.small nodes (2-4 nodes)
- VPC with CIDR 10.0.0.0/16
- RDS PostgreSQL 14.7 (db.t3.small, Multi-AZ)
- ElastiCache Redis 6.2 (cache.t2.micro)
- EFS filesystem
- S3 bucket with encryption (defaults to `${prefix}-operations`)

### App Stage (app/main.tf)

Key configuration:

```hcl
locals {
  url                            = "polytomic.example.com"  # Your domain
  domain                         = "example.com"             # Route53 zone
  polytomic_deployment           = "deployment"             # From Polytomic
  polytomic_deployment_key       = "key"                    # From Polytomic
  polytomic_api_key              = ""                       # Optional
  polytomic_image_tag            = "latest"                 # Use specific version
  polytomic_root_user            = "admin@example.com"      # Admin email
  polytomic_google_client_id     = "your-client-id"
  polytomic_google_client_secret = "your-client-secret"
}
```

Installs:

- AWS Load Balancer Controller
- EFS CSI Driver
- IAM roles (IRSA) for S3 access
- Polytomic Helm chart with external database configuration
- ACM certificate with automatic DNS validation

## Outputs

View all outputs:

```bash
cd cluster
terraform output

# View sensitive outputs
terraform output -raw postgres_password
terraform output -raw redis_auth_string
```

Available outputs:

- `cluster_name` - EKS cluster name
- `vpc_id` - VPC ID
- `public_subnets` - Public subnet IDs
- `postgres_host` - RDS endpoint
- `postgres_password` - RDS password (sensitive)
- `redis_host` - ElastiCache endpoint
- `redis_port` - Redis port (6379)
- `redis_auth_string` - Redis password (sensitive)
- `filesystem_id` - EFS filesystem ID
- `bucket` - S3 bucket name

## Cleanup

To destroy all resources (in reverse order):

```bash
# 1. Destroy application
cd app
terraform destroy

# 2. Destroy infrastructure
cd ../cluster
terraform destroy
```

**Warning**: This will delete all data. Ensure you have backups.

## Troubleshooting

### Pods Not Starting

```bash
kubectl describe pod -n polytomic <pod-name>
kubectl logs -n polytomic <pod-name>
```

Common issues:

- Image pull errors: Verify ECR credentials
- Database connection: Check security groups
- EFS mount: Verify EFS CSI driver is running

### Database Connection Errors

```bash
# Test connectivity
kubectl run -it --rm psql --image=postgres:15 -n polytomic -- \
  psql "postgresql://polytomic:PASSWORD@HOST:5432/polytomic?sslmode=require"
```

### Ingress Not Working

```bash
# Check ALB controller logs
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller

# Verify ALB was created
aws elbv2 describe-load-balancers --region us-west-2
```

## Additional Resources

- [EKS Modules Usage Guide](../../modules/eks/README-USAGE.md) - Comprehensive deployment guide
- [Helm Chart Documentation](../../../helm/charts/polytomic/README.md)
- [Development Testing Guide](../../../helm/README.dev.md)
