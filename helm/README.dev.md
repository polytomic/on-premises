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

## Testing on AWS (EKS with External Databases)

This section covers testing the Helm chart on AWS EKS with external managed services (RDS PostgreSQL and ElastiCache Redis).

### Prerequisites

- AWS CLI configured with appropriate credentials
- `eksctl` installed
- An existing EKS cluster (or use the terraform examples in `terraform/examples/eks-complete`)
- RDS PostgreSQL instance
- ElastiCache Redis cluster
- EFS filesystem (for shared volume)

### 1. Prepare AWS Resources

If using terraform:

```bash
cd terraform/examples/eks-complete/cluster
terraform init
terraform apply

# Note the outputs:
# - cluster_name
# - postgres_host
# - postgres_password
# - redis_host
# - filesystem_id (EFS)
```

### 2. Configure kubectl for EKS

```bash
aws eks update-kubeconfig --region us-west-2 --name <cluster-name>
kubectl get nodes
```

### 3. Install AWS Load Balancer Controller

```bash
# Install using Helm
helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=<cluster-name> \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```

### 4. Install EFS CSI Driver

```bash
# Install using Helm
helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver/
helm repo update

helm install aws-efs-csi-driver aws-efs-csi-driver/aws-efs-csi-driver \
  -n kube-system \
  --set controller.serviceAccount.create=false \
  --set controller.serviceAccount.name=efs-csi-controller-sa
```

### 5. Create EFS Storage Class

```bash
cat <<EOF | kubectl apply -f -
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: efs-sc
provisioner: efs.csi.aws.com
parameters:
  provisioningMode: efs-ap
  fileSystemId: fs-<your-efs-id>
  directoryPerms: "700"
EOF
```

### 6. Create AWS Test Values File

Create a values file for AWS testing with external databases:

```bash
cat > /tmp/polytomic-aws-values.yaml <<EOF
image:
  repository: 568237466542.dkr.ecr.us-west-2.amazonaws.com/polytomic-onprem
  tag: "latest"

ingress:
  enabled: true
  className: alb
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":443}]'
    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-west-2:ACCOUNT:certificate/CERT_ID
  hosts:
    - host: polytomic.example.com
      paths:
        - path: /
          pathType: Prefix

polytomic:
  deployment:
    name: "aws-test"
    key: "your-deployment-key"
    api_key: "your-api-key"

  auth:
    root_user: admin@example.com
    url: https://polytomic.example.com
    single_player: false
    google_client_id: "your-google-client-id"
    google_client_secret: "your-google-client-secret"
    methods:
      - google

  s3:
    operational_bucket: "s3://polytomic-operations"
    record_log_bucket: "polytomic-records"
    region: us-west-2

  sharedVolume:
    enabled: true
    mode: static
    size: 100Gi
    static:
      driver: efs.csi.aws.com
      volumeHandle: fs-<your-efs-id>

# Disable embedded databases
postgresql:
  enabled: false

redis:
  enabled: false

# Configure external databases
externalPostgresql:
  host: "polytomic.abc123.us-west-2.rds.amazonaws.com"
  port: 5432
  username: polytomic
  password: "YOUR_DB_PASSWORD"
  database: polytomic
  ssl: true
  sslMode: require
  poolSize: "15"
  autoMigrate: true

externalRedis:
  host: "polytomic.xyz789.0001.usw2.cache.amazonaws.com"
  port: 6379
  password: "YOUR_REDIS_PASSWORD"
  ssl: false

nfs-server-provisioner:
  enabled: false

minio:
  enabled: false

# Production-ready settings
web:
  replicaCount: 2
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 10

worker:
  replicaCount: 2

sync:
  replicaCount: 2
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 10

# Configure service account for IRSA (IAM Roles for Service Accounts)
serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::ACCOUNT:role/polytomic-role
EOF
```

### 7. Install on EKS

```bash
# Create namespace
kubectl create namespace polytomic

# Install the chart
helm install polytomic charts/polytomic \
  -f /tmp/polytomic-aws-values.yaml \
  --namespace polytomic

# Monitor installation
kubectl get pods -n polytomic -w
```

### 8. Verify AWS Integration

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

### 9. Testing External Database Failover

Test database resilience:

```bash
# Trigger RDS failover (Multi-AZ)
aws rds reboot-db-instance \
  --db-instance-identifier polytomic \
  --force-failover

# Monitor pods - they should reconnect automatically
kubectl logs -n polytomic -l app.kubernetes.io/component=web -f
```

### 10. AWS-Specific Debugging

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

### 11. Clean Up AWS Resources

```bash
# Uninstall chart
helm uninstall polytomic -n polytomic

# Delete namespace
kubectl delete namespace polytomic

# Clean up AWS resources (if using terraform)
cd terraform/examples/eks-complete/app
terraform destroy

cd ../cluster
terraform destroy
```

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
