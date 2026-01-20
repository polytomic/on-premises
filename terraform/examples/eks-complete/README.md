# Polytomic EKS Complete Example

This example demonstrates a complete production-ready Polytomic deployment on
AWS EKS using all three EKS Terraform modules.

## What This Example Includes

A two-stage deployment that creates:

**Stage 1: Infrastructure (cluster/)**

- EKS cluster with managed node groups
- VPC with public/private subnets across 3 AZs
- RDS PostgreSQL Multi-AZ database
- ElastiCache Redis cluster
- EFS filesystem for shared storage
- S3 bucket for operations and logs

**Stage 2: Application (app/)**

- AWS Load Balancer Controller
- EFS CSI Driver
- IAM roles (IRSA) for service accounts
- Polytomic Helm chart deployment

## Documentation

**For complete deployment instructions, see [EKS Deployment Guide](../../modules/eks/INSTALL.md)**

The comprehensive guide includes:

- Architecture diagrams
- Detailed prerequisites
- Step-by-step deployment instructions
- Configuration reference
- Troubleshooting scenarios

## Example-Specific Notes

This example differs from the comprehensive guide in that it:

**Does NOT manage DNS or TLS certificates**

- You must manually create CNAME records pointing to the ALB
- TLS can be handled externally (CloudFlare, CloudFront) or by providing an ACM certificate ARN
- See step 3d in the Quick Start below for TLS options

**Uses simplified configuration**

- Minimal viable settings for testing
- Defaults to HTTP (port 80) without certificate
- Suitable for proof-of-concept deployments

## Quick Start

### Prerequisites

Before starting, ensure you have:

- AWS CLI configured with appropriate credentials
- Terraform v1.0+
- kubectl and helm installed
- Polytomic license credentials (deployment name and key)
- Google OAuth credentials (or other auth method configured)

### Step 1: Deploy Infrastructure

```bash
cd cluster

# Edit main.tf and configure the locals block
# See INSTALL.md for detailed configuration options

terraform init
terraform apply
```

**Deployment time**: ~15-20 minutes

### Step 2: Deploy Application

```bash
cd ../app

# Edit main.tf and configure:
# - Polytomic deployment credentials
# - Domain name and authentication settings
# - Optional: certificate_arn if using ACM

terraform init
terraform apply
```

**Deployment time**: ~5-10 minutes

### Step 3: Configure DNS

```bash
# Get ALB hostname
kubectl get ingress -n polytomic polytomic -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Create CNAME record pointing your domain to the ALB hostname
# Example using Route53:
HOSTED_ZONE_ID="Z1234567890ABC"
DOMAIN_NAME="app.polytomic-local.com"
ALB_HOSTNAME=$(kubectl get ingress -n polytomic polytomic -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

aws route53 change-resource-record-sets \
  --hosted-zone-id $HOSTED_ZONE_ID \
  --change-batch "{
    \"Changes\": [{
      \"Action\": \"UPSERT\",
      \"ResourceRecordSet\": {
        \"Name\": \"$DOMAIN_NAME\",
        \"Type\": \"CNAME\",
        \"TTL\": 300,
        \"ResourceRecords\": [{\"Value\": \"$ALB_HOSTNAME\"}]
      }
    }]
  }"
```

### Step 4: Access Application

```bash
# Verify pods are running
kubectl get pods -n polytomic

# Access the application at your configured domain
# HTTP by default; HTTPS if certificate_arn was provided
```

## TLS Configuration Options

This example does not manage TLS certificates by default. Choose one of these options:

### Option 1: External TLS Termination (Recommended)

Use CloudFlare, CloudFront, or another CDN to handle TLS:

- The ALB serves HTTP on port 80
- Your CDN terminates TLS and forwards to ALB
- No ACM certificate needed

### Option 2: ACM Certificate

If you have an ACM certificate in the same AWS account/region:

```hcl
# In app/main.tf, add to eks_helm module:
module "eks_helm" {
  # ... existing config ...
  certificate_arn = "arn:aws:acm:us-east-2:123456789:certificate/your-cert-id"
}
```

### Option 3: Manual Certificate Creation

Uncomment the certificate resources at the bottom of [app/main.tf](app/main.tf), then:

```bash
cd app
terraform apply
terraform output certificate_arn

# Get validation records
aws acm describe-certificate --certificate-arn <arn> | \
  jq -r '.Certificate.DomainValidationOptions[0].ResourceRecord'
```

Add the CNAME validation record to your DNS provider, then the certificate will be issued.

## Configuration Files

**cluster/main.tf** - Infrastructure configuration

- EKS cluster settings (node size, count)
- Database configuration (RDS instance class, storage)
- Redis configuration (instance type, cluster size)
- VPC and networking

**app/main.tf** - Application configuration

- Polytomic deployment credentials
- Domain and authentication settings
- Helm chart values
- Optional ACM certificate

See [INSTALL.md](../../modules/eks/INSTALL.md) for detailed configuration options.

## Cleanup

Destroy resources in reverse order:

```bash
cd app && terraform destroy
cd ../cluster && terraform destroy
```

**Warning**: This permanently deletes all data. Ensure you have backups.

## Troubleshooting

For common issues, see the [Troubleshooting section in INSTALL.md](../../modules/eks/INSTALL.md#troubleshooting).

Quick diagnostics:

```bash
# Check pod status
kubectl get pods -n polytomic

# View pod logs
kubectl logs -n polytomic -l app.kubernetes.io/component=web --tail=50

# Check ALB controller
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
```

## Additional Resources

- [EKS Deployment Guide (INSTALL.md)](../../modules/eks/INSTALL.md) - Complete deployment documentation
- [eks Module README](../../modules/eks/README.md) - Module reference
- [eks-addons Module README](../../modules/eks-addons/README.md)
- [eks-helm Module README](../../modules/eks-helm/README.md)
- [Helm Chart Documentation](../../../helm/charts/polytomic/README.md)
