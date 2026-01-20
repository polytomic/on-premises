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
- Polytomic license (deployment name and key)
- Google OAuth credentials (client ID and secret)

**Note**: This example does not manage TLS certificates or DNS. You'll need to:
- Obtain the ALB DNS name after deployment
- Configure DNS (CNAME) in your DNS provider
- Handle TLS termination externally (CloudFlare, CloudFront, etc.) or provide an ACM certificate ARN

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
# - polytomic_deployment: Provided by Polytomic team
# - polytomic_deployment_key: Provided by Polytomic team
# - polytomic_api_key: Optional API key
# - polytomic_image_tag: Use specific version (not "latest" for production)
# - polytomic_root_user: Your admin email
# - polytomic_google_client_id: Google OAuth client ID
# - polytomic_google_client_secret: Google OAuth secret
#
# Optional: If you have an ACM certificate, add to eks_helm module:
# certificate_arn = "arn:aws:acm:us-east-2:123456789:certificate/your-cert-id"

terraform init
terraform plan
terraform apply
```

**Time**: 5-10 minutes

### Step 3: Configure DNS and Access

```bash
# Configure kubectl
aws eks update-kubeconfig --region us-east-2 --name polytomic-testing-cluster

# Check deployment status
kubectl get pods -n polytomic

# Get ALB DNS name
kubectl get ingress -n polytomic polytomic -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

**DNS Configuration**:
1. The command above returns the ALB hostname (e.g., `k8s-polytomic-xxx.elb.us-east-2.amazonaws.com`)
2. Create a CNAME record in your DNS provider:
   - Name: `polytomic.example.com` (your domain from locals.url)
   - Type: CNAME
   - Value: The ALB hostname from above

**TLS Configuration**:
- **Without certificate**: The ALB listens on HTTP (port 80). Use CloudFlare, CloudFront, or another CDN for TLS termination
- **With ACM certificate**: Pass `certificate_arn` to the eks_helm module in main.tf. The ALB will listen on HTTPS (port 443)

Navigate to your configured URL to access Polytomic.

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
  polytomic_deployment           = "deployment"             # From Polytomic
  polytomic_deployment_key       = "key"                    # From Polytomic
  polytomic_api_key              = ""                       # Optional
  polytomic_image_tag            = "rel2025.01.07"          # Use specific version
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
- Application Load Balancer (HTTP by default; HTTPS if certificate_arn provided)

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
