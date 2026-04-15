# Terraform Module Upgrade Guide: Helm Chart v1.0.0

## Overview

The Polytomic Helm chart has been upgraded to **v1.0.0**, which includes breaking changes to the configuration structure. This guide helps you update your Terraform modules that deploy Polytomic using the `eks-helm` or `gke-helm` modules.

**⚠️ IMPORTANT:** Helm chart v1.0.0 introduces breaking configuration changes. You MUST update your Terraform modules before upgrading.

## What Changed

### Helm Chart v1.0.0 Breaking Changes

1. **Database Configuration**: Replaced `polytomic.postgres.*` and `polytomic.redis.*` with `externalPostgresql.*` and `externalRedis.*`
2. **Shared Volume**: Replaced `polytomic.cache.*` with `polytomic.sharedVolume.*`
3. **PostgreSQL Dependency**: Upgraded from 12.1.9 → 16.2.3
4. **Redis Dependency**: Upgraded from 17.4.3 → 20.5.0

### Terraform Module Changes

Both `eks-helm` and `gke-helm` modules have been updated to use the new configuration structure.

## Affected Modules

- `terraform/modules/eks-helm` - EKS Helm deployment
- `terraform/modules/gke-helm` - GKE Helm deployment

## Migration Steps

### Step 1: Review Current Configuration

Check your current Terraform code that uses these modules:

```bash
# Find all references to eks-helm or gke-helm modules
grep -r "eks-helm\|gke-helm" terraform/
```

### Step 2: Update Module Source (if using git references)

If you're referencing modules from git, update to use the latest version:

```hcl
# Before
module "eks_helm" {
  source = "github.com/polytomic/on-premises/terraform/modules/eks-helm?ref=v0.0.18"
  # ...
}

# After
module "eks_helm" {
  source = "github.com/polytomic/on-premises/terraform/modules/eks-helm?ref=v1.0.0"
  # ...
}
```

### Step 3: No Variable Changes Required

**Good news:** The module variables have NOT changed. The breaking changes are internal to the module's Helm values configuration.

You do NOT need to change:
- `postgres_host`
- `postgres_password`
- `redis_host`
- `redis_port`
- `redis_password`
- `efs_id` (EKS only)
- Any other variables

### Step 4: Update Terraform

```bash
cd terraform/examples/eks-complete/app  # or your terraform directory

# Re-initialize to update module source
terraform init -upgrade

# Review the changes
terraform plan

# Apply the changes
terraform apply
```

## Configuration Changes Details

### EKS Module Changes

#### Before (v0.0.x):
```hcl
# In terraform/modules/eks-helm/main.tf
polytomic:
  redis:
    username:
    password: ${var.redis_password}
    host: ${var.redis_host}
    port: ${var.redis_port}

  postgres:
    username: polytomic
    password: ${var.postgres_password}
    host: ${var.postgres_host}

  cache:
    storage_class: efs-sc
    enabled: true
    type: static
    efs_id: ${var.efs_id}
    size: 10Gi
```

#### After (v1.0.0):
```hcl
# In terraform/modules/eks-helm/main.tf
# Disable embedded databases
postgresql:
  enabled: false

redis:
  enabled: false

# Configure external PostgreSQL (RDS)
externalPostgresql:
  host: ${var.postgres_host}
  port: 5432
  username: polytomic
  password: ${var.postgres_password}
  database: polytomic
  ssl: true
  sslMode: require
  poolSize: "15"
  autoMigrate: true

# Configure external Redis (ElastiCache)
externalRedis:
  host: ${var.redis_host}
  port: ${var.redis_port}
  password: ${var.redis_password}
  ssl: false

# Shared volume (EFS)
polytomic:
  sharedVolume:
    enabled: true
    mode: static
    size: 10Gi
    static:
      driver: efs.csi.aws.com
      volumeHandle: ${var.efs_id}
```

### GKE Module Changes

#### Before (v0.0.x):
```hcl
# In terraform/modules/gke-helm/main.tf
polytomic:
  redis:
    username:
    password: ${var.redis_password}
    host: ${var.redis_host}
    port: ${var.redis_port}

  postgres:
    username: polytomic
    password: ${var.postgres_password}
    host: ${var.postgres_host}
```

#### After (v1.0.0):
```hcl
# In terraform/modules/gke-helm/main.tf
# Disable embedded databases
postgresql:
  enabled: false

redis:
  enabled: false

# Configure external PostgreSQL (Cloud SQL)
externalPostgresql:
  host: ${var.postgres_host}
  port: 5432
  username: polytomic
  password: ${var.postgres_password}
  database: polytomic
  ssl: false
  poolSize: "15"
  autoMigrate: true

# Configure external Redis (MemoryStore)
externalRedis:
  host: ${var.redis_host}
  port: ${var.redis_port}
  password: ${var.redis_password}
  ssl: false

# Shared volume (dynamic provisioning)
polytomic:
  sharedVolume:
    enabled: true
    mode: dynamic
    size: 20Gi
```

## Testing the Upgrade

### 1. Test with Terraform Plan

Always run `terraform plan` first to review changes:

```bash
terraform plan
```

**Expected changes:**
- Helm release will show an update (in-place)
- No resource replacements should occur
- Chart version changes from 0.0.x to 1.0.0

### 2. Test in Non-Production First

Test the upgrade in a development or staging environment before production:

```bash
# Development environment
cd terraform/examples/eks-complete/app
terraform workspace select dev
terraform apply

# Verify the application works
kubectl get pods -n polytomic
```

### 3. Monitor the Upgrade

Watch pods during the upgrade:

```bash
# In another terminal, watch the rollout
kubectl get pods -n polytomic -w

# Check for any errors
kubectl logs -n polytomic -l app.kubernetes.io/name=polytomic --tail=100 -f
```

## Rollback Procedure

If you encounter issues:

### Option 1: Terraform Rollback

```bash
# Revert your Terraform code to the previous module version
git checkout HEAD~1 terraform/examples/eks-complete/app/main.tf

# Re-apply
terraform apply
```

### Option 2: Helm Rollback

```bash
# List helm releases
helm list -n polytomic

# Rollback to previous revision
helm rollback polytomic -n polytomic

# Update Terraform state to match
terraform refresh
```

## Validation

After upgrading, validate the deployment:

```bash
# Check all pods are running
kubectl get pods -n polytomic
# All pods should be in Running state

# Verify database connectivity
kubectl exec -it -n polytomic deployment/polytomic-web -- \
  sh -c 'echo "SELECT version();" | psql $DATABASE_URL'

# Verify Redis connectivity
kubectl exec -it -n polytomic deployment/polytomic-web -- \
  sh -c 'redis-cli -h $REDIS_HOST -p $REDIS_PORT -a $REDIS_PASSWORD ping'

# Check application health
kubectl exec -it -n polytomic deployment/polytomic-web -- \
  curl -s http://localhost:5100/status.txt
# Should return: OK

# Verify EFS/shared volume (EKS only)
kubectl exec -it -n polytomic deployment/polytomic-worker -- \
  df -h /var/polytomic
```

## Troubleshooting

### Issue: Helm upgrade fails with validation errors

**Cause:** Chart version mismatch or incompatible values

**Solution:**
```bash
# Check current chart version
helm list -n polytomic

# Force upgrade if needed
terraform apply -replace="module.eks_helm.helm_release.polytomic"
```

### Issue: Database connection errors after upgrade

**Cause:** Configuration values not properly applied

**Solution:**
```bash
# Check the secret contains correct values
kubectl get secret -n polytomic polytomic-config -o yaml

# Verify environment variables in pod
kubectl exec -it -n polytomic deployment/polytomic-web -- env | grep -E "DATABASE|REDIS"

# Restart deployments to pick up new config
kubectl rollout restart deployment/polytomic-web -n polytomic
kubectl rollout restart deployment/polytomic-worker -n polytomic
kubectl rollout restart deployment/polytomic-sync -n polytomic
```

### Issue: PVC/Volume mount errors

**Cause:** Shared volume configuration changed

**Solution (EKS with EFS):**
```bash
# Check if EFS StorageClass exists
kubectl get storageclass efs-sc

# Verify PV and PVC
kubectl get pv,pvc -n polytomic

# Check EFS CSI driver is running
kubectl get pods -n kube-system -l app=efs-csi-controller
```

### Issue: Terraform state drift

**Cause:** Manual changes or Helm release updated outside Terraform

**Solution:**
```bash
# Import current Helm release state
terraform import module.eks_helm.helm_release.polytomic polytomic/polytomic

# Or refresh state
terraform refresh
terraform plan
```

## Example: Complete EKS Upgrade

Here's a complete example of upgrading an EKS deployment:

```bash
# 1. Backup current state
terraform show > terraform-state-backup.txt
kubectl get all -n polytomic > k8s-resources-backup.yaml

# 2. Update module source
vim main.tf
# Change module source to v1.0.0

# 3. Initialize and review
terraform init -upgrade
terraform plan > plan.txt
cat plan.txt  # Review carefully

# 4. Apply in a maintenance window
terraform apply

# 5. Monitor the rollout
kubectl get pods -n polytomic -w

# 6. Validate
./validate.sh  # Your validation script

# 7. Test the application
curl https://polytomic.example.com/status.txt
```

## Example: Complete GKE Upgrade

```bash
# 1. Backup current state
terraform show > terraform-state-backup.txt
kubectl get all -n polytomic -o yaml > k8s-resources-backup.yaml

# 2. Update module source
vim main.tf
# Change module source to v1.0.0

# 3. Initialize and review
terraform init -upgrade
terraform plan -out=plan.tfplan

# 4. Apply
terraform apply plan.tfplan

# 5. Monitor
kubectl get pods -n polytomic -w

# 6. Validate Cloud SQL and MemoryStore connectivity
gcloud sql operations list --instance=polytomic-db
kubectl logs -n polytomic -l app.kubernetes.io/name=polytomic --tail=50
```

## FAQ

### Q: Will this cause downtime?

**A:** The upgrade performs a rolling update of pods. With default replica counts (2+ replicas), there should be no downtime. However, we recommend performing the upgrade during a maintenance window.

### Q: Do I need to migrate database data?

**A:** No, the PostgreSQL and Redis data is not affected. Only the configuration structure changes. However, note that the embedded PostgreSQL dependency upgraded from version 12→15. If you're using embedded databases (not recommended for production), you may need to migrate data separately.

### Q: Can I keep using the old configuration?

**A:** No, Helm chart v1.0.0 requires the new configuration structure. The old `polytomic.postgres.*` and `polytomic.redis.*` fields are deprecated.

### Q: What if I'm using local Helm chart (not via Terraform)?

**A:** See the main Helm chart upgrade guide: `helm/UPGRADE-v1.0.md`

### Q: Do I need to update my RDS or ElastiCache instances?

**A:** No, your existing RDS PostgreSQL and ElastiCache Redis instances are not affected. Only the Helm configuration changes.

### Q: What about the EFS filesystem?

**A:** Your existing EFS filesystem is not affected. The Terraform module now uses the new `sharedVolume.static.volumeHandle` parameter instead of `cache.efs_id`, but both reference the same EFS filesystem ID.

### Q: Can I test this without Terraform?

**A:** Yes, you can manually install the Helm chart with the new values structure:

```bash
helm repo update
helm upgrade polytomic polytomic/polytomic \
  --version 1.0.0 \
  -f values.yaml \
  --namespace polytomic
```

## Additional Resources

- [Helm Chart v1.0.0 Upgrade Guide](../helm/UPGRADE-v1.0.md)
- [Helm Chart Testing Guide](../helm/README.dev.md)
- [Terraform Module Documentation](./README.md)
- [EKS Helm Module README](./modules/eks-helm/README.md)
- [GKE Helm Module README](./modules/gke-helm/README.md)

## Support

If you encounter issues during the upgrade:

1. Check the [Troubleshooting](#troubleshooting) section above
2. Review Terraform plan output carefully
3. Check Helm release status: `helm status polytomic -n polytomic`
4. Review pod logs: `kubectl logs -n polytomic -l app.kubernetes.io/name=polytomic`
5. Contact Polytomic support with:
   - Terraform version
   - Module version (before/after)
   - Terraform plan output
   - Helm chart version
   - Error messages from Terraform and Kubernetes

## Summary

**Key Points:**
- ✅ No Terraform variable changes required
- ✅ Module internal configuration updated for Helm v1.0.0 compatibility
- ✅ Rolling update - minimal/no downtime expected
- ✅ External databases (RDS, ElastiCache, Cloud SQL, MemoryStore) unaffected
- ⚠️ Test in non-production first
- ⚠️ Perform during maintenance window
- ⚠️ Monitor pod rollout during upgrade

**Required Actions:**
1. Update module source to v1.0.0 (if using git references)
2. Run `terraform init -upgrade`
3. Run `terraform plan` and review
4. Run `terraform apply`
5. Validate deployment

**No Action Required For:**
- Module variables (all unchanged)
- RDS/ElastiCache instances
- EFS filesystems
- VPC/networking
- IAM roles
