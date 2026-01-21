# Polytomic EKS Deployment Guide

<<<<<<< HEAD
This is the comprehensive deployment guide for Polytomic on AWS EKS using the
three EKS Terraform modules (eks, eks-addons, eks-helm).

> **Note**: If you're using the [eks-complete
> example](../../examples/eks-complete/), refer to that README for
> example-specific quick start instructions, then return here for detailed
> configuration and troubleshooting.
=======
This guide provides comprehensive instructions for deploying Polytomic on AWS EKS using the three EKS Terraform modules.
>>>>>>> master

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Module Overview](#module-overview)
- [Prerequisites](#prerequisites)
- [Deployment Steps](#deployment-steps)
- [Module Configuration](#module-configuration)
- [Outputs and Integration](#outputs-and-integration)
- [Post-Deployment](#post-deployment)
- [Troubleshooting](#troubleshooting)

## Architecture Overview

The EKS deployment consists of three layers, each managed by a separate Terraform module:

```
┌─────────────────────────────────────────────────────────────┐
│                     eks Module                               │
│  ┌────────────┐  ┌──────────┐  ┌────────┐  ┌──────┐       │
│  │ EKS Cluster│  │ RDS      │  │ Redis  │  │ EFS  │       │
│  │            │  │ Postgres │  │ Cache  │  │      │       │
│  │  + VPC     │  └──────────┘  └────────┘  └──────┘       │
│  └────────────┘                                             │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                  eks-addons Module                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ AWS LB       │  │ EFS CSI      │  │ IAM Roles    │     │
│  │ Controller   │  │ Driver       │  │ (IRSA)       │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                  eks-helm Module                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         Polytomic Helm Chart                         │  │
│  │  ┌──────┐  ┌────────┐  ┌──────┐  ┌─────┐          │  │
│  │  │ Web  │  │ Worker │  │ Sync │  │ Dev │          │  │
│  │  └──────┘  └────────┘  └──────┘  └─────┘          │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Module Overview

### 1. eks Module (`terraform/modules/eks`)

**Purpose**: Provisions the foundational infrastructure for Polytomic

**Creates**:

- **EKS Cluster**: Kubernetes 1.24+ cluster with managed node groups
- **VPC**: Optional VPC with public/private subnets across multiple AZs
- **RDS PostgreSQL**: Optional managed PostgreSQL database (version 14+)
- **ElastiCache Redis**: Optional managed Redis cluster (version 6.2+)
- **EFS**: Optional Elastic File System for shared storage
- **S3 Bucket**: Storage for Polytomic operations and logs
- **Security Groups**: Configured for database, Redis, and EFS access
- **VPC Endpoint**: S3 VPC endpoint for private S3 access

**Key Features**:

- Multi-AZ deployment for high availability
- Conditional resource creation (can use existing resources)
- Production-ready defaults with monitoring and backups
- Encrypted storage (at-rest and in-transit)

### 2. eks-addons Module (`terraform/modules/eks-addons`)

**Purpose**: Installs essential Kubernetes controllers and configures IAM permissions

**Deploys**:

- **AWS Load Balancer Controller**: Manages ALB/NLB for ingress
- **EFS CSI Driver**: Enables EFS volume mounting in pods
- **EBS CSI Driver**: Enables EBS volume provisioning
- **IAM Roles for Service Accounts (IRSA)**:
  - Load balancer controller role
  - EFS CSI controller role
  - EBS CSI controller/node roles
  - Polytomic application role (S3 access)

**Key Features**:

- IRSA integration for secure AWS API access
- Automatic storage class creation for EFS
- Regional endpoint configuration for AWS STS

### 3. eks-helm Module (`terraform/modules/eks-helm`)

**Purpose**: Deploys the Polytomic Helm chart with production configuration

**Configures**:

- **Ingress**: ALB with HTTPS termination
- **Application Components**:
  - Web deployment (API, frontend)
  - Worker deployment (background jobs)
  - Sync deployment (data synchronization)
  - Dev deployment (optional, disabled by default)
- **External Services**:
  - RDS PostgreSQL connection with SSL
  - ElastiCache Redis connection
  - EFS shared volume mounting
  - S3 bucket configuration
- **Authentication**: Google OAuth, Microsoft, SSO, or single-player mode
- **Security**: Service account with IRSA annotations

**Key Features**:

- Uses Helm chart v1.0.0+ with new configuration structure
- Disables embedded PostgreSQL/Redis (uses external managed services)
- Configures health probes and resource limits
- Supports autoscaling for web and sync deployments

## Prerequisites

### Required Tools

```bash
# Terraform
brew install terraform  # v1.0+

# AWS CLI
brew install awscli

# kubectl
brew install kubectl

# Helm
brew install helm
```

### AWS Configuration

1. **AWS Account** with permissions to create:
   - EKS clusters
   - RDS databases
   - ElastiCache clusters
   - EFS file systems
   - S3 buckets
   - IAM roles and policies
   - VPC resources

2. **AWS Credentials** configured:

   ```bash
   aws configure
   # or
   export AWS_PROFILE=your-profile
   ```

3. **Route53 Hosted Zone** (for domain validation):
   - Required for ACM certificate validation
   - Domain must be registered and zone created

4. **Polytomic License**:
   - Deployment ID
   - Deployment key

5. **ECR Access** (if using private Polytomic image):
   ```bash
   aws ecr get-login-password --region us-west-2 | \
     docker login --username AWS --password-stdin \
     568237466542.dkr.ecr.us-west-2.amazonaws.com
   ```

## Deployment Steps

### Step 1: Provision Infrastructure (eks module)

Create a directory for your cluster configuration:

```bash
mkdir -p polytomic-deployment/cluster
cd polytomic-deployment/cluster
```

Create `main.tf`:

```hcl
locals {
  region  = "us-west-2"
  prefix  = "polytomic"
  vpc_azs = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

provider "aws" {
  region = local.region
}

module "eks" {
  source = "github.com/polytomic/on-premises//terraform/modules/eks?ref=v1.0.0"

  prefix      = local.prefix
  region      = local.region
  vpc_azs     = local.vpc_azs
  bucket_name = "${local.prefix}-operations"

  # Optional: Use existing VPC
  # vpc_id             = "vpc-xxxxx"
  # private_subnet_ids = ["subnet-xxxxx", "subnet-yyyyy", "subnet-zzzzz"]

  # Optional: Disable resource creation if using existing resources
  # create_postgres = false
  # create_redis    = false
  # create_efs      = false

  # Database configuration
  database_instance_class = "db.t3.medium"
  database_allocated_storage = 50
  database_multi_az = true

  # Redis configuration
  redis_instance_type = "cache.t3.medium"
  redis_cluster_size  = "2"

  # Node group configuration
  instance_type = "t3.large"
  min_size      = 2
  max_size      = 10
  desired_size  = 3

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

Create `outputs.tf`:

```hcl
output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_arn" {
  value = module.eks.cluster_arn
}

output "vpc_id" {
  value = module.eks.vpc_id
}

output "public_subnets" {
  value = module.eks.public_subnets
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "postgres_host" {
  value = module.eks.postgres_host
}

output "postgres_password" {
  value     = module.eks.postgres_password
  sensitive = true
}

output "redis_host" {
  value = module.eks.redis_host
}

output "redis_port" {
  value = module.eks.redis_port
}

output "redis_auth_string" {
  value     = module.eks.redis_auth_string
  sensitive = true
}

output "filesystem_id" {
  value = module.eks.filesystem_id
}

output "bucket" {
  value = module.eks.bucket
}
```

Deploy the infrastructure:

```bash
terraform init
terraform plan
terraform apply
```

**Time**: 15-20 minutes

### Step 2: Install Kubernetes Add-ons (eks-addons module)

Create a directory for your application configuration:

```bash
mkdir -p ../app
cd ../app
```

Create `main.tf`:

```hcl
locals {
  region = "us-west-2"
  prefix = "polytomic"
}

# Reference the cluster state
data "terraform_remote_state" "eks" {
  backend = "local"
  config = {
    path = "../cluster/terraform.tfstate"
  }
}

# Configure kubectl access
data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# Install add-ons
module "addons" {
  source = "github.com/polytomic/on-premises//terraform/modules/eks-addons?ref=v1.0.0"

  prefix            = local.prefix
  region            = local.region
  cluster_name      = data.terraform_remote_state.eks.outputs.cluster_name
  vpc_id            = data.terraform_remote_state.eks.outputs.vpc_id
  oidc_provider_arn = data.terraform_remote_state.eks.outputs.oidc_provider_arn
  efs_id            = data.terraform_remote_state.eks.outputs.filesystem_id
}
```

Deploy the add-ons:

```bash
terraform init
terraform plan
terraform apply
```

**Time**: 3-5 minutes

### Step 3: Deploy Polytomic Application (eks-helm module)

Add to your `app/main.tf`:

```hcl
locals {
  # ... existing locals ...

  url                            = "polytomic.example.com"
  domain                         = "example.com"
  polytomic_deployment           = "your-deployment-name"     # Provided by Polytomic
  polytomic_deployment_key       = "your-deployment-key"      # Provided by Polytomic
  polytomic_api_key              = "your-api-key"             # Optional
  polytomic_image                = "568237466542.dkr.ecr.us-west-2.amazonaws.com/polytomic-onprem"
  polytomic_image_tag            = "rel2024.12.01"            # Use specific version
  polytomic_root_user            = "admin@example.com"
  polytomic_google_client_id     = "your-google-client-id"
  polytomic_google_client_secret = "your-google-client-secret"
}

# Create ACM certificate for HTTPS
resource "aws_acm_certificate" "cert" {
  domain_name       = local.url
  validation_method = "DNS"
}

data "aws_route53_zone" "zone" {
  name = local.domain
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.zone.zone_id
}

resource "aws_acm_certificate_validation" "validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# Deploy Polytomic
module "eks_helm" {
  source = "github.com/polytomic/on-premises//terraform/modules/eks-helm?ref=v1.0.0"

  certificate_arn                    = aws_acm_certificate.cert.arn
  subnets                            = join(",", data.terraform_remote_state.eks.outputs.public_subnets)
  polytomic_url                      = local.url
  polytomic_deployment               = local.polytomic_deployment
  polytomic_deployment_key           = local.polytomic_deployment_key
  polytomic_api_key                  = local.polytomic_api_key
  polytomic_image                    = local.polytomic_image
  polytomic_image_tag                = local.polytomic_image_tag
  polytomic_root_user                = local.polytomic_root_user
  redis_host                         = data.terraform_remote_state.eks.outputs.redis_host
  redis_port                         = data.terraform_remote_state.eks.outputs.redis_port
  redis_password                     = data.terraform_remote_state.eks.outputs.redis_auth_string
  postgres_host                      = data.terraform_remote_state.eks.outputs.postgres_host
  postgres_password                  = data.terraform_remote_state.eks.outputs.postgres_password
  polytomic_google_client_id         = local.polytomic_google_client_id
  polytomic_google_client_secret     = local.polytomic_google_client_secret
  polytomic_bucket                   = data.terraform_remote_state.eks.outputs.bucket
  polytomic_bucket_region            = local.region
  efs_id                             = data.terraform_remote_state.eks.outputs.filesystem_id
  polytomic_service_account_role_arn = module.addons.polytomic_role_arn

  depends_on = [
    module.addons,
    aws_acm_certificate_validation.validation
  ]
}
```

Deploy the application:

```bash
terraform apply
```

**Time**: 5-10 minutes

### Step 4: Configure kubectl Access

```bash
aws eks update-kubeconfig --region us-west-2 --name polytomic-cluster
kubectl get nodes
kubectl get pods -n polytomic
```

### Step 5: Get ALB DNS Name

```bash
kubectl get ingress -n polytomic

# Output:
# NAME        CLASS   HOSTS                    ADDRESS
# polytomic   alb     polytomic.example.com    k8s-polytomi-xxxxxxxx-xxxxxxxxxx.us-west-2.elb.amazonaws.com
```

### Step 6: Create DNS Record

Create a CNAME record in Route53 pointing your domain to the ALB:

```bash
# Via Terraform (add to app/main.tf):
resource "aws_route53_record" "polytomic" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = local.url
  type    = "CNAME"
  ttl     = 300
  records = [
    # Get this from: kubectl get ingress -n polytomic -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}'
    "k8s-polytomi-xxxxxxxx-xxxxxxxxxx.us-west-2.elb.amazonaws.com"
  ]
}
```

Or create manually in the AWS Console.

## Module Configuration

### eks Module Variables

<details>
<summary>Core Configuration</summary>

| Variable             | Description                          | Type           | Default                                      | Required |
| -------------------- | ------------------------------------ | -------------- | -------------------------------------------- | -------- |
| `prefix`             | Prefix for all resources             | `string`       | `"polytomic"`                                | no       |
| `region`             | AWS region                           | `string`       | `"us-east-1"`                                | no       |
| `vpc_id`             | Existing VPC ID (empty = create new) | `string`       | `""`                                         | no       |
| `vpc_cidr`           | VPC CIDR block                       | `string`       | `"10.0.0.0/16"`                              | no       |
| `vpc_azs`            | Availability zones                   | `list(string)` | `["us-east-1a", "us-east-1b", "us-east-1c"]` | no       |
| `private_subnet_ids` | Existing private subnet IDs          | `list(string)` | `[]`                                         | no       |
| `public_subnet_ids`  | Existing public subnet IDs           | `list(string)` | `[]`                                         | no       |
| `bucket_name`        | S3 bucket name                       | `string`       | `"polytomic-bucket"`                         | no       |
| `tags`               | Resource tags                        | `map(string)`  | `{}`                                         | no       |

</details>

<details>
<summary>EKS Configuration</summary>

| Variable        | Description        | Default      |
| --------------- | ------------------ | ------------ |
| `instance_type` | Node instance type | `"t3.small"` |
| `min_size`      | Minimum nodes      | `2`          |
| `max_size`      | Maximum nodes      | `4`          |
| `desired_size`  | Desired nodes      | `3`          |

</details>

<details>
<summary>PostgreSQL Configuration</summary>

| Variable                     | Description             | Default         |
| ---------------------------- | ----------------------- | --------------- |
| `create_postgres`            | Create RDS instance     | `true`          |
| `database_name`              | Database name           | `"polytomic"`   |
| `database_username`          | Database username       | `"polytomic"`   |
| `database_engine_version`    | PostgreSQL version      | `"14.7"`        |
| `database_instance_class`    | Instance type           | `"db.t3.small"` |
| `database_allocated_storage` | Storage (GB)            | `20`            |
| `database_multi_az`          | Enable Multi-AZ         | `true`          |
| `database_backup_retention`  | Backup retention (days) | `30`            |

</details>

<details>
<summary>Redis Configuration</summary>

| Variable               | Description                        | Default            |
| ---------------------- | ---------------------------------- | ------------------ |
| `create_redis`         | Create Redis cluster               | `true`             |
| `redis_instance_type`  | Node type                          | `"cache.t2.micro"` |
| `redis_cluster_size`   | Number of nodes                    | `"1"`              |
| `redis_engine_version` | Redis version                      | `"6.2"`            |
| `redis_auth_token`     | Auth token (empty = auto-generate) | `""`               |

</details>

<details>
<summary>EFS Configuration</summary>

| Variable     | Description | Default |
| ------------ | ----------- | ------- |
| `create_efs` | Create EFS  | `true`  |

</details>

### eks-helm Module Variables

| Variable                             | Description                         | Required |
| ------------------------------------ | ----------------------------------- | -------- |
| `certificate_arn`                    | ACM certificate ARN                 | yes      |
| `subnets`                            | Public subnet IDs (comma-separated) | yes      |
| `polytomic_url`                      | Application domain                  | yes      |
| `polytomic_deployment`               | Deployment name                     | yes      |
| `polytomic_deployment_key`           | Deployment key                      | yes      |
| `polytomic_api_key`                  | API key                             | no       |
| `polytomic_image`                    | Container image                     | yes      |
| `polytomic_image_tag`                | Image tag                           | yes      |
| `polytomic_root_user`                | Initial admin email                 | yes      |
| `postgres_host`                      | PostgreSQL host                     | yes      |
| `postgres_password`                  | PostgreSQL password                 | yes      |
| `redis_host`                         | Redis host                          | yes      |
| `redis_port`                         | Redis port                          | yes      |
| `redis_password`                     | Redis password                      | no       |
| `polytomic_google_client_id`         | Google OAuth client ID              | yes      |
| `polytomic_google_client_secret`     | Google OAuth secret                 | yes      |
| `polytomic_bucket`                   | S3 bucket name                      | yes      |
| `polytomic_bucket_region`            | S3 bucket region                    | yes      |
| `efs_id`                             | EFS filesystem ID                   | yes      |
| `polytomic_service_account_role_arn` | IAM role ARN                        | yes      |

## Outputs and Integration

### eks Module Outputs

```hcl
# Use these outputs in the eks-addons and eks-helm modules
module.eks.cluster_name            # EKS cluster name
module.eks.cluster_arn             # EKS cluster ARN
module.eks.vpc_id                  # VPC ID
module.eks.public_subnets          # Public subnet IDs
module.eks.oidc_provider_arn       # OIDC provider ARN
module.eks.postgres_host           # RDS endpoint
module.eks.postgres_password       # RDS password (sensitive)
module.eks.redis_host              # ElastiCache endpoint
module.eks.redis_port              # ElastiCache port
module.eks.redis_auth_string       # Redis password (sensitive)
module.eks.filesystem_id           # EFS filesystem ID
module.eks.bucket                  # S3 bucket name
```

### eks-addons Module Outputs

```hcl
module.addons.polytomic_role_arn   # IAM role ARN for Polytomic pods
```

## Post-Deployment

### Verify Deployment

```bash
# Check all pods are running
kubectl get pods -n polytomic

# Expected output:
# NAME                              READY   STATUS    RESTARTS   AGE
# polytomic-web-xxxxxxxxxx-xxxxx    1/1     Running   0          5m
# polytomic-web-xxxxxxxxxx-yyyyy    1/1     Running   0          5m
# polytomic-worker-xxxxxxxxx-xxxxx  1/1     Running   0          5m
# polytomic-worker-xxxxxxxxx-yyyyy  1/1     Running   0          5m
# polytomic-sync-xxxxxxxxxx-xxxxx   1/1     Running   0          5m
# polytomic-sync-xxxxxxxxxx-yyyyy   1/1     Running   0          5m

# Check services
kubectl get svc -n polytomic

# Check ingress
kubectl get ingress -n polytomic

# View logs
kubectl logs -n polytomic -l app.kubernetes.io/component=web --tail=50
```

### Access the Application

1. Navigate to `https://polytomic.example.com`
2. Sign in with Google OAuth using the root user email
3. Complete initial setup

### Configure Google OAuth

Ensure your Google Cloud Console OAuth app has:

**Authorized JavaScript origins**:

```
https://polytomic.example.com
```

**Authorized redirect URIs**:

```
https://polytomic.example.com/api/auth/callback/google
```

## Troubleshooting

### Pods Not Starting

```bash
# Describe pod to see events
kubectl describe pod -n polytomic <pod-name>

# Check logs
kubectl logs -n polytomic <pod-name>

# Common issues:
# - Image pull errors: Check ECR credentials
# - Database connection: Verify security groups allow traffic
# - EFS mount: Check EFS security group and mount targets
```

### Database Connection Errors

```bash
# Test database connectivity from a pod
kubectl run -it --rm psql --image=postgres:15 -n polytomic -- \
  psql "postgresql://polytomic:PASSWORD@HOST:5432/polytomic?sslmode=require"

# Check security group rules
aws ec2 describe-security-groups \
  --group-ids <database-sg-id> \
  --query 'SecurityGroups[0].IpPermissions'
```

### Redis Connection Errors

```bash
# Test Redis connectivity
kubectl run -it --rm redis --image=redis:7 -n polytomic -- \
  redis-cli -h <redis-host> -p 6379 -a <password> ping

# Should return: PONG
```

### EFS Mount Issues

```bash
# Check EFS mount targets
aws efs describe-mount-targets --file-system-id <efs-id>

# Verify EFS security group
aws ec2 describe-security-groups --group-ids <efs-sg-id>

# Check EFS CSI driver
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-efs-csi-driver
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-efs-csi-driver --tail=50
```

### Ingress/ALB Issues

```bash
# Check ALB controller logs
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller --tail=50

# Verify ALB was created
aws elbv2 describe-load-balancers \
  --query 'LoadBalancers[?contains(LoadBalancerName, `k8s-polytomi`)].{Name:LoadBalancerName,DNS:DNSName,State:State.Code}'

# Check target group health
aws elbv2 describe-target-health \
  --target-group-arn <target-group-arn>
```

### SSL/Certificate Issues

```bash
# Verify ACM certificate is issued
aws acm describe-certificate --certificate-arn <cert-arn>

# Check certificate on ALB
aws elbv2 describe-listeners \
  --load-balancer-arn <alb-arn> \
  --query 'Listeners[?Port==`443`].Certificates'
```

### Viewing Terraform State

```bash
# Show all outputs
terraform output

# Show sensitive output
terraform output -raw postgres_password
terraform output -raw redis_auth_string
```

### Clean Up Resources

To destroy all resources (in reverse order):

```bash
# 1. Destroy application
cd app
terraform destroy

# 2. Destroy infrastructure
cd ../cluster
terraform destroy
```

**Warning**: This will delete all data. Ensure you have backups before proceeding.

## Additional Resources

- [EKS Module README](./README.md)
- [eks-addons Module README](../eks-addons/README.md)
- [eks-helm Module README](../eks-helm/README.md)
- [Polytomic Helm Chart Documentation](../../../helm/charts/polytomic/README.md)
- [Helm Chart Development Guide](../../../helm/README.dev.md)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
