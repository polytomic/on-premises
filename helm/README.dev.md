# Polytomic Helm Chart - Development & Testing Guide

This guide provides comprehensive instructions for testing the Polytomic Helm chart in a local Kubernetes environment.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Local Environment Setup](#local-environment-setup)
- [Installing Dependencies](#installing-dependencies)
- [Testing the Chart](#testing-the-chart)
- [Debugging](#debugging)
- [Cleanup](#cleanup)
- [Common Issues](#common-issues)

## Prerequisites

### Required Tools

- [Docker Desktop](https://www.docker.com/products/docker-desktop) (for macOS/Windows) or Docker Engine (for Linux)
- [kind](https://kind.sigs.k8s.io/) - Kubernetes in Docker
- [kubectl](https://kubernetes.io/docs/tasks/tools/) - Kubernetes CLI
- [helm](https://helm.sh/docs/intro/install/) - Helm 3.x
- [helm-docs](https://github.com/norwoodj/helm-docs) - For generating chart documentation

### Installation Commands

```bash
# Install kind
brew install kind  # macOS
# or
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64 && chmod +x ./kind && sudo mv ./kind /usr/local/bin/kind  # Linux

# Install kubectl
brew install kubectl  # macOS
# or
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && chmod +x kubectl && sudo mv kubectl /usr/local/bin/  # Linux

# Install helm
brew install helm  # macOS
# or
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash  # Linux

# Install helm-docs
brew install norwoodj/tap/helm-docs  # macOS
# or
GO111MODULE=on go install github.com/norwoodj/helm-docs/cmd/helm-docs@latest  # Linux
```

## Local Environment Setup

### 1. Create a kind Cluster

Create a kind cluster with an ingress-ready configuration:

```bash
cat <<EOF | kind create cluster --name polytomic-dev --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
  extraMounts:
  - hostPath: /tmp/polytomic-data
    containerPath: /data
EOF
```

Verify the cluster is running:

```bash
kubectl cluster-info --context kind-polytomic-dev
kubectl get nodes
```

### 2. Install NGINX Ingress Controller

The Polytomic chart uses nginx ingress by default:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Wait for the ingress controller to be ready
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
```

### 3. Setup Local DNS (Optional)

Add an entry to `/etc/hosts` for local testing:

```bash
echo "127.0.0.1 polytomic.local" | sudo tee -a /etc/hosts
```

## Installing Dependencies

### 1. Update Helm Chart Dependencies

Navigate to the chart directory and update dependencies:

```bash
cd /Users/nathanyergler/p/on-premises/helm/charts/polytomic

# Update dependencies
helm dependency update

# Verify dependencies are downloaded
ls -la charts/
```

This will download:

- PostgreSQL (Bitnami)
- Redis (Bitnami)
- nfs-server-provisioner

### 2. Configure Image Pull Secrets

The Polytomic image is in a private ECR repository, so create an image pull secret:

```bash
# For AWS ECR
aws ecr get-login-password --region us-west-2 | \
  kubectl create secret docker-registry polytomic-ecr \
  --docker-server=568237466542.dkr.ecr.us-west-2.amazonaws.com \
  --docker-username=AWS \
  --docker-password-stdin
```

## Testing the Chart

### 1. Create a Test Values File

Create a minimal values file for local testing:

```bash
cat > /tmp/polytomic-test-values.yaml <<EOF
image:
  repository: 568237466542.dkr.ecr.us-west-2.amazonaws.com/polytomic-onprem
  tag: "latest"
  pullPolicy: IfNotPresent

imagePullSecrets:
  - name: polytomic-ecr

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: polytomic.local
      paths:
        - path: /
          pathType: Prefix

polytomic:
  deployment:
    name: "local-dev"
    key: "your-deployment-key"
    api_key: "your-api-key"

  auth:
    root_user: admin@example.com
    url: http://polytomic.local
    single_player: true

  s3:
    operational_bucket: "s3://test-operations"
    record_log_bucket: "test-records"
    region: us-east-1

  sharedVolume:
    enabled: true
    mode: dynamic
    size: 1Gi

# Use embedded databases for local development
postgresql:
  enabled: true
  auth:
    username: polytomic
    password: polytomic
    database: polytomic
  primary:
    persistence:
      enabled: true
      size: 2Gi

redis:
  enabled: true
  auth:
    password: polytomic
    enabled: true
  architecture: standalone
  master:
    persistence:
      enabled: true
      size: 2Gi

nfs-server-provisioner:
  enabled: true
  persistence:
    enabled: true
    size: 5Gi

# Reduce resources for local testing
web:
  replicaCount: 1
  autoscaling:
    enabled: false
  resources:
    requests:
      cpu: 100m
      memory: 256Mi
    limits:
      cpu: 500m
      memory: 512Mi

worker:
  replicaCount: 1
  autoscaling:
    enabled: false
  resources:
    requests:
      cpu: 100m
      memory: 256Mi
    limits:
      cpu: 500m
      memory: 512Mi

sync:
  replicaCount: 1
  autoscaling:
    enabled: false
  resources:
    requests:
      cpu: 100m
      memory: 256Mi
    limits:
      cpu: 500m
      memory: 512Mi

development: false
EOF
```

### 2. Validate the Chart

Before installation, validate the chart:

```bash
# Lint the chart
helm lint charts/polytomic -f /tmp/polytomic-test-values.yaml

# Render templates and check for errors
helm template polytomic charts/polytomic -f /tmp/polytomic-test-values.yaml --debug

# Dry-run installation
helm install polytomic charts/polytomic \
  -f /tmp/polytomic-test-values.yaml \
  --dry-run --debug
```

### 3. Install the Chart

Install the chart to your kind cluster:

```bash
helm install polytomic charts/polytomic \
  -f /tmp/polytomic-test-values.yaml \
  --create-namespace \
  --namespace polytomic
```

### 4. Monitor the Installation

Watch the pods come up:

```bash
# Watch all pods in the namespace
kubectl get pods -n polytomic -w

# Check the status of all resources
kubectl get all -n polytomic

# View the deployment status
helm status polytomic -n polytomic
```

### 5. Access the Application

Once all pods are running:

```bash
# Port forward if not using ingress
kubectl port-forward -n polytomic svc/polytomic 8080:80

# Or access via ingress (if configured)
open http://polytomic.local
```

### 6. Run Helm Tests

Execute the built-in Helm tests:

```bash
helm test polytomic -n polytomic
```

## Debugging

### View Logs

```bash
# Web service logs
kubectl logs -n polytomic -l app.kubernetes.io/name=polytomic-web -f

# Worker logs
kubectl logs -n polytomic -l app.kubernetes.io/name=polytomic-worker -f

# Sync service logs
kubectl logs -n polytomic -l app.kubernetes.io/name=polytomic-sync -f

# PostgreSQL logs
kubectl logs -n polytomic -l app.kubernetes.io/name=postgresql -f

# Redis logs
kubectl logs -n polytomic -l app.kubernetes.io/name=redis -f
```

### Describe Resources

```bash
# Describe a failing pod
kubectl describe pod -n polytomic <pod-name>

# Check events
kubectl get events -n polytomic --sort-by='.lastTimestamp'

# Check persistent volume claims
kubectl get pvc -n polytomic
```

### Interactive Debugging

```bash
# Execute into a pod
kubectl exec -it -n polytomic <pod-name> -- /bin/sh

# Check environment variables
kubectl exec -it -n polytomic <pod-name> -- env | sort

# Check secret contents (base64 decoded)
kubectl get secret -n polytomic polytomic-config -o jsonpath='{.data}' | jq -r 'to_entries[] | "\(.key)=\(.value | @base64d)"'
```

### Common Debug Commands

```bash
# Check if services are accessible
kubectl run -it --rm debug --image=busybox --restart=Never -n polytomic -- wget -O- http://polytomic:80

# Test PostgreSQL connectivity
kubectl run -it --rm psql --image=postgres:15 --restart=Never -n polytomic -- \
  psql postgresql://polytomic:polytomic@polytomic-postgresql:5432/polytomic -c '\l'

# Test Redis connectivity
kubectl run -it --rm redis --image=redis:7 --restart=Never -n polytomic -- \
  redis-cli -h polytomic-redis-master -a polytomic ping
```

## Upgrading the Chart

After making changes to the chart:

```bash
# Update dependencies if Chart.yaml changed
helm dependency update charts/polytomic

# Upgrade the release
helm upgrade polytomic charts/polytomic \
  -f /tmp/polytomic-test-values.yaml \
  --namespace polytomic

# Rollback if needed
helm rollback polytomic -n polytomic
```

## Cleanup

### Uninstall the Release

```bash
# Uninstall the Helm release
helm uninstall polytomic -n polytomic

# Delete the namespace
kubectl delete namespace polytomic

# Delete PVCs if they persist
kubectl delete pvc --all -n polytomic
```

### Delete the kind Cluster

```bash
kind delete cluster --name polytomic-dev
```

### Remove hosts entry

```bash
sudo sed -i '' '/polytomic.local/d' /etc/hosts  # macOS
# or
sudo sed -i '/polytomic.local/d' /etc/hosts     # Linux
```

## Common Issues

### Issue: ImagePullBackOff

**Symptoms**: Pods stuck in `ImagePullBackOff` state

**Solutions**:

- Verify image pull secrets are configured correctly
- Check AWS credentials for ECR access
- Ensure the image tag exists in the repository
- Try pulling the image manually with `docker pull`

```bash
# Recreate ECR secret
kubectl delete secret polytomic-ecr -n polytomic
aws ecr get-login-password --region us-west-2 | \
  kubectl create secret docker-registry polytomic-ecr -n polytomic \
  --docker-server=568237466542.dkr.ecr.us-west-2.amazonaws.com \
  --docker-username=AWS \
  --docker-password-stdin
```

### Issue: Pods CrashLooping

**Symptoms**: Pods restarting repeatedly

**Solutions**:

- Check logs: `kubectl logs -n polytomic <pod-name> --previous`
- Verify database migrations completed
- Check database connectivity
- Verify all required environment variables are set

### Issue: PVC Pending

**Symptoms**: PersistentVolumeClaims stuck in `Pending` state

**Solutions**:

- Check if storage class exists: `kubectl get sc`
- Verify nfs-server-provisioner is running
- Check provisioner logs: `kubectl logs -n polytomic -l app=nfs-server-provisioner`

```bash
# Check PVC status
kubectl describe pvc -n polytomic polytomic-cache

# Manually create a local-path storage class for kind
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
```

### Issue: Ingress Not Working

**Symptoms**: Cannot access application via ingress

**Solutions**:

- Verify ingress controller is running: `kubectl get pods -n ingress-nginx`
- Check ingress resource: `kubectl describe ingress -n polytomic`
- Verify DNS/hosts file configuration
- Test with port-forward instead

### Issue: Database Connection Failed

**Symptoms**: Errors about database connectivity in logs

**Solutions**:

- Verify PostgreSQL is running: `kubectl get pods -n polytomic -l app.kubernetes.io/name=postgresql`
- Check PostgreSQL service: `kubectl get svc -n polytomic polytomic-postgresql`
- Test connection from a debug pod
- Verify credentials in secret match PostgreSQL configuration

## Testing on AWS (EKS with Terraform Modules)

This section covers testing the Helm chart on AWS EKS using the official Polytomic Terraform modules, which provide a production-ready infrastructure setup.

### Overview

The EKS Terraform modules provide three layers of infrastructure:

1. **eks module**: Provisions EKS cluster, VPC, RDS, Redis, EFS, and S3
2. **eks-addons module**: Installs AWS Load Balancer Controller, EFS CSI Driver, and IAM roles
3. **eks-helm module**: Deploys the Polytomic Helm chart with production configuration

This approach is recommended for testing because it:

- Mirrors production deployment patterns
- Automatically configures all dependencies correctly
- Validates module compatibility with the Helm chart
- Provides repeatable, infrastructure-as-code testing

### Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform installed (v1.0+)
- kubectl installed
- Helm installed
- AWS permissions to create EKS, RDS, ElastiCache, EFS, S3, VPC resources
- Route53 hosted zone for domain validation (if testing ingress with HTTPS)

### 1. Prepare AWS Resources with Terraform

#### Option A: Using the eks-complete Example (Recommended)

The `terraform/examples/eks-complete` example provides a complete, ready-to-use setup:

```bash
cd terraform/examples/eks-complete/cluster

# Create terraform.tfvars with your configuration
cat > terraform.tfvars <<EOF
# Update these values for your environment
prefix = "polytomic-test"
region = "us-west-2"
vpc_azs = ["us-west-2a", "us-west-2b", "us-west-2c"]
bucket_name = "polytomic-test-operations"
EOF

terraform init
terraform plan
terraform apply

# Note the outputs - you'll need these:
# - cluster_name
# - postgres_host
# - postgres_password (sensitive)
# - redis_host
# - redis_port
# - redis_auth_string (sensitive)
# - filesystem_id (EFS)
# - bucket
# - vpc_id
# - public_subnets
# - oidc_provider_arn
```

**Time**: 15-20 minutes

#### Option B: Using Modules Directly

If you want more control, use the modules directly:

```bash
mkdir -p polytomic-test/cluster
cd polytomic-test/cluster

# Create main.tf
cat > main.tf <<'EOF'
locals {
  region  = "us-west-2"
  prefix  = "polytomic-test"
  vpc_azs = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

provider "aws" {
  region = local.region
}

module "eks" {
  source = "../../terraform/modules/eks"

  prefix      = local.prefix
  region      = local.region
  vpc_azs     = local.vpc_azs
  bucket_name = "${local.prefix}-operations"

  # Use smaller instances for testing
  database_instance_class = "db.t3.small"
  database_allocated_storage = 20
  redis_instance_type = "cache.t3.micro"
  instance_type = "t3.medium"
  min_size = 2
  max_size = 4
  desired_size = 2

  tags = {
    Environment = "test"
    Purpose     = "helm-chart-testing"
  }
}

output "cluster_name" { value = module.eks.cluster_name }
output "vpc_id" { value = module.eks.vpc_id }
output "public_subnets" { value = module.eks.public_subnets }
output "oidc_provider_arn" { value = module.eks.oidc_provider_arn }
output "postgres_host" { value = module.eks.postgres_host }
output "postgres_password" { value = module.eks.postgres_password, sensitive = true }
output "redis_host" { value = module.eks.redis_host }
output "redis_port" { value = module.eks.redis_port }
output "redis_auth_string" { value = module.eks.redis_auth_string, sensitive = true }
output "filesystem_id" { value = module.eks.filesystem_id }
output "bucket" { value = module.eks.bucket }
EOF

terraform init
terraform apply
```

### 2. Install EKS Add-ons

Before deploying the Helm chart, install the necessary Kubernetes controllers:

```bash
cd ../app  # or create this directory if using custom setup

# Create main.tf for add-ons
cat > main.tf <<'EOF'
locals {
  region = "us-west-2"
  prefix = "polytomic-test"
}

data "terraform_remote_state" "eks" {
  backend = "local"
  config = {
    path = "../cluster/terraform.tfstate"
  }
}

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

module "addons" {
  source = "../../terraform/modules/eks-addons"

  prefix            = local.prefix
  region            = local.region
  cluster_name      = data.terraform_remote_state.eks.outputs.cluster_name
  vpc_id            = data.terraform_remote_state.eks.outputs.vpc_id
  oidc_provider_arn = data.terraform_remote_state.eks.outputs.oidc_provider_arn
  efs_id            = data.terraform_remote_state.eks.outputs.filesystem_id
}

output "polytomic_role_arn" {
  value = module.addons.polytomic_role_arn
}
EOF

terraform init
terraform apply
```

**Time**: 3-5 minutes

This installs:

- AWS Load Balancer Controller (for ALB ingress)
- EFS CSI Driver (for shared volume support)
- IAM roles with proper IRSA configuration

### 3. Configure kubectl for EKS

```bash
aws eks update-kubeconfig --region us-west-2 --name polytomic-test-cluster
kubectl get nodes

# Verify add-ons are running
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-efs-csi-driver
```

### 4. Deploy Using eks-helm Module (Automated)

The `eks-helm` module provides the easiest way to test the Helm chart with proper configuration:

```bash
# Add to your app/main.tf
cat >> main.tf <<'EOF'

# You'll need these values - update accordingly
locals {
  url                            = "polytomic-test.example.com"  # Your domain
  domain                         = "example.com"                 # Your Route53 zone
  polytomic_deployment           = "test-deployment"             # From Polytomic team
  polytomic_deployment_key       = "test-key"                    # From Polytomic team
  polytomic_api_key              = ""                            # Optional
  polytomic_image                = "568237466542.dkr.ecr.us-west-2.amazonaws.com/polytomic-onprem"
  polytomic_image_tag            = "latest"                      # Use specific version in production
  polytomic_root_user            = "admin@example.com"
  polytomic_google_client_id     = "your-google-client-id"
  polytomic_google_client_secret = "your-google-client-secret"
}

# Create ACM certificate
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

# Deploy Polytomic with eks-helm module
module "eks_helm" {
  source = "../../terraform/modules/eks-helm"

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
EOF

terraform apply
```

**Time**: 5-10 minutes

This automatically:

- Deploys the Polytomic Helm chart with v1.0.0 configuration
- Configures external PostgreSQL and Redis
- Sets up EFS shared volume with static provisioning
- Configures ALB ingress with HTTPS
- Applies production-ready resource limits and health probes

### 5. Manual Helm Installation (Alternative)

If you want to test Helm chart changes directly without using the eks-helm module:

#### a. Create Test Values File

Extract Terraform outputs and create a values file:

```bash
# Get values from Terraform
cd ../app
CLUSTER_NAME=$(terraform output -raw cluster_name 2>/dev/null || terraform output cluster_name)
POSTGRES_HOST=$(cd ../cluster && terraform output -raw postgres_host)
POSTGRES_PASSWORD=$(cd ../cluster && terraform output -raw postgres_password)
REDIS_HOST=$(cd ../cluster && terraform output -raw redis_host)
REDIS_PORT=$(cd ../cluster && terraform output -raw redis_port)
REDIS_PASSWORD=$(cd ../cluster && terraform output -raw redis_auth_string)
EFS_ID=$(cd ../cluster && terraform output -raw filesystem_id)
BUCKET=$(cd ../cluster && terraform output -raw bucket)
ROLE_ARN=$(terraform output -raw polytomic_role_arn)

# Create values file
cat > /tmp/polytomic-test-eks.yaml <<EOF
image:
  repository: 568237466542.dkr.ecr.us-west-2.amazonaws.com/polytomic-onprem
  tag: "latest"  # Use specific version in production

polytomic:
  deployment:
    name: "test-deployment"          # Your deployment name
    key: "test-key"                  # Your deployment key
    api_key: ""                      # Optional API key

  auth:
    root_user: admin@example.com     # Update with your email
    url: https://polytomic-test.example.com  # Your domain
    single_player: false
    google_client_id: "your-google-client-id"
    google_client_secret: "your-google-client-secret"
    methods:
      - google

  s3:
    operational_bucket: "s3://\${BUCKET}"
    record_log_bucket: "\${BUCKET}"
    region: us-west-2

  sharedVolume:
    enabled: true
    mode: static
    size: 100Gi
    static:
      driver: efs.csi.aws.com
      volumeHandle: \${EFS_ID}

# Disable embedded databases - use external managed services
postgresql:
  enabled: false

redis:
  enabled: false

# Configure external PostgreSQL (RDS)
externalPostgresql:
  host: "\${POSTGRES_HOST}"
  port: 5432
  username: polytomic
  password: "\${POSTGRES_PASSWORD}"
  database: polytomic
  ssl: true
  sslMode: require
  poolSize: "15"
  autoMigrate: true

# Configure external Redis (ElastiCache)
externalRedis:
  host: "\${REDIS_HOST}"
  port: \${REDIS_PORT}
  password: "\${REDIS_PASSWORD}"
  ssl: false

nfs-server-provisioner:
  enabled: false

minio:
  enabled: false

# Reduce resources for testing (increase for production)
web:
  replicaCount: 1
  resources:
    limits:
      cpu: 500m
      memory: 1Gi
    requests:
      cpu: 250m
      memory: 512Mi

worker:
  replicaCount: 1
  resources:
    limits:
      cpu: 500m
      memory: 1Gi
    requests:
      cpu: 250m
      memory: 512Mi

sync:
  replicaCount: 1
  resources:
    limits:
      cpu: 500m
      memory: 1Gi
    requests:
      cpu: 250m
      memory: 512Mi

# Configure service account for IRSA
serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: \${ROLE_ARN}
    eks.amazonaws.com/sts-regional-endpoints: "true"
EOF
```

#### b. Install the Chart

```bash
# Navigate to helm directory
cd ../../helm

# Update chart dependencies
cd charts/polytomic
helm dependency update
cd ../..

# Install the chart
helm install polytomic charts/polytomic \
  -f /tmp/polytomic-test-eks.yaml \
  --create-namespace \
  --namespace polytomic

# Monitor installation
kubectl get pods -n polytomic -w
```

**Time**: 2-3 minutes for pods to start

#### c. Verify Installation

```bash
# Check all pods are running
kubectl get pods -n polytomic

# Expected output:
# NAME                              READY   STATUS    RESTARTS   AGE
# polytomic-web-xxxxxxxxxx-xxxxx    1/1     Running   0          2m
# polytomic-worker-xxxxxxxxx-xxxxx  1/1     Running   0          2m
# polytomic-sync-xxxxxxxxxx-xxxxx   1/1     Running   0          2m

# Check services and ingress
kubectl get svc,ingress -n polytomic

# View logs
kubectl logs -n polytomic -l app.kubernetes.io/component=web --tail=50
```

### 6. Verify AWS Integration

```bash
# Check pods are running
kubectl get pods -n polytomic

# Verify database connectivity
kubectl exec -it -n polytomic deployment/polytomic-web -- \
  sh -c 'psql $DATABASE_URL -c "SELECT version();"'

# Verify Redis connectivity
kubectl exec -it -n polytomic deployment/polytomic-web -- \
  sh -c 'redis-cli -h $REDIS_HOST -p $REDIS_PORT -a $REDIS_PASSWORD ping'

# Check EFS mount
kubectl exec -it -n polytomic deployment/polytomic-worker -- \
  df -h /var/polytomic

# Get ALB hostname
kubectl get ingress -n polytomic
```

### 7. Testing Helm Chart Changes

When testing Helm chart modifications:

```bash
# Make changes to the chart
cd helm/charts/polytomic
# Edit templates or values.yaml

# Update dependencies if Chart.yaml changed
helm dependency update

# Test template rendering
helm template polytomic . -f /tmp/polytomic-test-eks.yaml --debug

# Upgrade the release
helm upgrade polytomic . \
  -f /tmp/polytomic-test-eks.yaml \
  --namespace polytomic

# Watch pods restart
kubectl get pods -n polytomic -w

# Check for issues
kubectl get events -n polytomic --sort-by='.lastTimestamp' | head -20
```

### 8. Testing External Database Failover

Test database resilience:

```bash
# Trigger RDS failover (Multi-AZ)
aws rds reboot-db-instance \
  --db-instance-identifier polytomic \
  --force-failover

# Monitor pods - they should reconnect automatically
kubectl logs -n polytomic -l app.kubernetes.io/component=web -f
```

### 9. AWS-Specific Debugging

```bash
# Check IAM role permissions
aws sts assume-role \
  --role-arn arn:aws:iam::ACCOUNT:role/polytomic-role \
  --role-session-name test

# Test S3 access
kubectl exec -it -n polytomic deployment/polytomic-worker -- \
  aws s3 ls s3://polytomic-operations/

# Check security groups
aws ec2 describe-security-groups \
  --filters Name=tag:Name,Values=polytomic-*

# Verify EFS access
kubectl run -it --rm efs-test --image=busybox -n polytomic \
  --overrides='{"spec":{"containers":[{"name":"efs-test","image":"busybox","command":["sh"],"volumeMounts":[{"name":"efs","mountPath":"/efs"}]}],"volumes":[{"name":"efs","persistentVolumeClaim":{"claimName":"polytomic-shared"}}]}}'
```

### 10. Clean Up AWS Resources

**Important**: Always clean up in the correct order to avoid orphaned resources.

#### If Using Terraform Modules:

```bash
# 1. Destroy application and add-ons
cd app
terraform destroy

# 2. Destroy cluster infrastructure
cd ../cluster
terraform destroy
```

#### If Using Manual Helm Installation:

```bash
# 1. Uninstall Helm chart
helm uninstall polytomic -n polytomic

# 2. Delete namespace
kubectl delete namespace polytomic

# 3. Destroy add-ons and infrastructure
cd app
terraform destroy

cd ../cluster
terraform destroy
```

**Estimated time**: 10-15 minutes

**Cost Savings**: Always destroy test environments when not in use to avoid unnecessary AWS charges.

### Terraform Module Documentation

For comprehensive information about the EKS Terraform modules:

- [EKS Modules Usage Guide](../../terraform/modules/eks/README-USAGE.md) - Complete deployment guide
- [eks module README](../../terraform/modules/eks/README.md) - Infrastructure module documentation
- [eks-addons module README](../../terraform/modules/eks-addons/README.md) - Add-ons module documentation
- [eks-helm module README](../../terraform/modules/eks-helm/README.md) - Helm deployment module documentation

## Advanced Testing

### Load Testing

```bash
# Install hey for load testing
go install github.com/rakyll/hey@latest

# Run load test
hey -z 30s -c 10 http://polytomic.local
```

### Testing Upgrades

```bash
# Test upgrade from previous version
helm upgrade polytomic charts/polytomic \
  -f /tmp/polytomic-test-values.yaml \
  --namespace polytomic \
  --set image.tag=new-version
```

### Testing Scaling

```bash
# Scale web deployment
kubectl scale deployment -n polytomic polytomic-web --replicas=3

# Enable HPA for testing
helm upgrade polytomic charts/polytomic \
  -f /tmp/polytomic-test-values.yaml \
  --set web.autoscaling.enabled=true \
  --namespace polytomic
```

## Generating Documentation

After making changes to values.yaml:

```bash
cd charts/polytomic
helm-docs
```

This will regenerate the README.md from README.md.gotmpl and values.yaml comments.

## Additional Resources

- [kind Documentation](https://kind.sigs.k8s.io/)
- [Helm Documentation](https://helm.sh/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
- [Bitnami PostgreSQL Chart](https://github.com/bitnami/charts/tree/main/bitnami/postgresql)
- [Bitnami Redis Chart](https://github.com/bitnami/charts/tree/main/bitnami/redis)
