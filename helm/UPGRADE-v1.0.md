# Upgrade Guide: v0.0.x → v1.0.0

## Overview

Version 1.0.0 is a **MAJOR BREAKING RELEASE** that modernizes the Helm chart architecture. This upgrade contains significant changes to database configuration, storage, and deployment defaults.

**⚠️ IMPORTANT:** This is NOT a drop-in replacement. You MUST update your `values.yaml` configuration.

## Breaking Changes Summary

1. **[BREAKING]** PostgreSQL and Redis are now pluggable (embedded vs external)
2. **[BREAKING]** Shared volume configuration completely refactored
3. **[BREAKING]** Image tag default changed from `"latest"` to `""` (uses Chart.appVersion)
4. **[BREAKING]** PostgreSQL dependency upgraded: 12.1.9 → 16.2.3 (PostgreSQL 12 → 15)
5. **[BREAKING]** Redis dependency upgraded: 17.4.3 → 20.5.0
6. **[BREAKING]** Default replica counts changed to 2 for all deployments
7. **[BREAKING]** Autoscaling enabled by default for web and sync deployments
8. **[BREAKING]** Resource limits now set by default (previously unlimited)

## Prerequisites

- Helm 3.8+
- Kubernetes 1.24+
- Backup your data before upgrading (see "Backup Procedure" below)

## Migration Path

### Option A: Fresh Installation (Recommended)

If you're doing a fresh installation or can afford downtime:

1. **Backup existing data** (PostgreSQL, Redis, S3 buckets)
2. **Uninstall old chart**:
   ```bash
   helm uninstall polytomic
   ```
3. **Update values.yaml** (see "Configuration Changes" below)
4. **Install new chart**:
   ```bash
   helm install polytomic polytomic/polytomic -f values.yaml --version 1.0.0
   ```
5. **Restore data** if needed

### Option B: In-Place Upgrade (Advanced)

For production systems requiring minimal downtime:

1. **Backup existing data**
2. **Update values.yaml** (see "Configuration Changes" below)
3. **Disable embedded databases** (use external):
   ```yaml
   postgresql:
     enabled: false
   redis:
     enabled: false
   ```
4. **Set up external databases** (RDS, ElastiCache, etc.)
5. **Migrate data** from embedded to external databases
6. **Run upgrade**:
   ```bash
   helm upgrade polytomic polytomic/polytomic -f values.yaml --version 1.0.0
   ```

## Configuration Changes

### 1. Database Configuration

#### Before (v0.0.x):
```yaml
polytomic:
  postgres:
    username: polytomic
    password: polytomic
    host: polytomic-postgresql
    port: 5432
    database: polytomic
    ssl: false
  redis:
    password: polytomic
    host: polytomic-redis-master
    port: 6379
    ssl: false

postgresql:
  enabled: true
  auth:
    username: polytomic
    password: polytomic
    database: polytomic

redis:
  enabled: true
  auth:
    password: polytomic
```

#### After (v1.0.0):

**Option 1: Embedded Databases (Development/Testing)**
```yaml
# Use embedded PostgreSQL and Redis (Bitnami subcharts)
postgresql:
  enabled: true
  auth:
    username: polytomic
    password: polytomic
    database: polytomic
  primary:
    persistence:
      enabled: true
      size: 8Gi

redis:
  enabled: true
  auth:
    enabled: true
    password: polytomic
  architecture: standalone
  master:
    persistence:
      enabled: true
      size: 8Gi

# DEPRECATED: polytomic.postgres and polytomic.redis sections
# These are still present for backward compatibility but will be removed in v2.0.0
```

**Option 2: External Databases (Production - Recommended)**
```yaml
# Disable embedded databases
postgresql:
  enabled: false

redis:
  enabled: false

# Configure external PostgreSQL (RDS, CloudSQL, etc.)
externalPostgresql:
  host: "polytomic.abc123.us-west-2.rds.amazonaws.com"
  port: 5432
  username: "polytomic"
  password: "YOUR_PASSWORD"  # Or use existingSecret
  database: "polytomic"
  ssl: true
  sslMode: "require"
  poolSize: "15"
  idleTimeout: "5s"
  autoMigrate: true
  # Optional: Use existing secret
  # existingSecret:
  #   name: "polytomic-db-secret"
  #   key: "postgresql-password"

# Configure external Redis (ElastiCache, MemoryStore, etc.)
externalRedis:
  host: "polytomic.xyz789.0001.usw2.cache.amazonaws.com"
  port: 6379
  password: "YOUR_PASSWORD"  # Or use existingSecret
  ssl: false
  poolSize: 0
  # Optional: Use existing secret
  # existingSecret:
  #   name: "polytomic-redis-secret"
  #   key: "redis-password"
```

### 2. Shared Volume Configuration

#### Before (v0.0.x):
```yaml
polytomic:
  cache:
    enabled: true
    volume_name: polytomic-cache
    size: 20Mi
    storage_class: ""
    # Complex EFS-specific configuration
    type: static
    efs_id: fs-12345678
```

#### After (v1.0.0):
```yaml
polytomic:
  sharedVolume:
    enabled: true
    mode: dynamic  # Options: "dynamic", "static", "emptyDir"
    size: 20Gi  # Changed from 20Mi to 20Gi (reasonable default)
    mountPath: /var/polytomic
    accessModes:
      - ReadWriteMany
    volumeName: polytomic-shared
    subPath: ""

    # For static provisioning (pre-existing PV like EFS)
    static:
      driver: efs.csi.aws.com
      volumeHandle: "fs-12345678"  # Your EFS filesystem ID
      volumeAttributes: {}
        # path: /

    # For dynamic provisioning (StorageClass)
    dynamic:
      storageClassName: ""  # Empty = use cluster default

  # DEPRECATED: cache section (kept for backward compatibility)
  # Will be removed in v2.0.0
```

**Migration Examples:**

**Dynamic Provisioning (Default):**
```yaml
polytomic:
  sharedVolume:
    enabled: true
    mode: dynamic
    size: 20Gi
    dynamic:
      storageClassName: ""  # Uses cluster default StorageClass
```

**Static EFS Provisioning:**
```yaml
polytomic:
  sharedVolume:
    enabled: true
    mode: static
    size: 100Gi
    static:
      driver: efs.csi.aws.com
      volumeHandle: "fs-abc12345"
      volumeAttributes:
        path: /polytomic
```

**Disable Persistent Storage (EmptyDir):**
```yaml
polytomic:
  sharedVolume:
    enabled: false  # Or set mode: emptyDir
    mode: emptyDir
```

### 3. Image Tag Configuration

#### Before (v0.0.x):
```yaml
image:
  repository: 568237466542.dkr.ecr.us-west-2.amazonaws.com/polytomic-onprem
  tag: "latest"
```

#### After (v1.0.0):
```yaml
image:
  repository: 568237466542.dkr.ecr.us-west-2.amazonaws.com/polytomic-onprem
  tag: ""  # Empty = uses Chart.appVersion

# For production, ALWAYS specify a concrete version:
# tag: "rel2024.11.04"
# See https://docs.polytomic.com/changelog
```

**Action Required:** Update your values.yaml to specify an explicit image tag for production deployments.

### 4. Resource Limits (New Defaults)

#### Before (v0.0.x):
No default resource limits were set.

#### After (v1.0.0):
All deployments now have default resource limits:

```yaml
web:
  replicaCount: 2  # Changed from 1
  resources:
    limits:
      cpu: 1000m
      memory: 2Gi
    requests:
      cpu: 500m
      memory: 1Gi
  autoscaling:
    enabled: true  # Changed from false
    minReplicas: 2
    maxReplicas: 10

worker:
  replicaCount: 2  # Changed from 1
  resources:
    limits:
      cpu: 500m
      memory: 1Gi
    requests:
      cpu: 250m
      memory: 512Mi
  autoscaling:
    enabled: false

sync:
  replicaCount: 2  # Changed from 1
  resources:
    limits:
      cpu: 1000m
      memory: 2Gi
    requests:
      cpu: 500m
      memory: 1Gi
  autoscaling:
    enabled: true  # Changed from false
    minReplicas: 2
    maxReplicas: 10

dev:
  enabled: false
  resources:
    limits:
      cpu: 500m
      memory: 1Gi
    requests:
      cpu: 100m
      memory: 256Mi
```

**Action Required:** Adjust resource limits based on your workload. These are conservative defaults.

### 5. NFS Server Provisioner

The `nfs-server-provisioner` is still supported but updated to use the new registry:

#### After (v1.0.0):
```yaml
nfs-server-provisioner:
  enabled: true  # Or false if using cloud storage
  image:
    repository: registry.k8s.io/sig-storage/nfs-provisioner  # Changed from k8s.gcr.io
    tag: v4.0.8  # Updated from v3.0.1
```

## Backup Procedure

### Backup PostgreSQL

```bash
# For embedded PostgreSQL
kubectl exec -it polytomic-postgresql-0 -- \
  pg_dump -U polytomic polytomic > polytomic-backup-$(date +%Y%m%d).sql

# For external PostgreSQL (RDS, etc.)
pg_dump -h YOUR_RDS_HOST -U polytomic polytomic > polytomic-backup-$(date +%Y%m%d).sql
```

### Backup Redis

```bash
# For embedded Redis
kubectl exec -it polytomic-redis-master-0 -- redis-cli SAVE
kubectl cp polytomic-redis-master-0:/data/dump.rdb ./redis-backup-$(date +%Y%m%d).rdb

# For external Redis (ElastiCache)
# Use AWS backup functionality or redis-cli BGSAVE
```

### Backup S3 Data

```bash
# Sync S3 buckets
aws s3 sync s3://your-operations-bucket s3://your-backup-bucket/operations/
aws s3 sync s3://your-records-bucket s3://your-backup-bucket/records/
```

## Validation

After upgrading, validate the deployment:

```bash
# Check all pods are running
kubectl get pods -l app.kubernetes.io/name=polytomic

# Check web deployment
kubectl rollout status deployment/polytomic-web

# Check worker deployment
kubectl rollout status deployment/polytomic-worker

# Check sync deployment
kubectl rollout status deployment/polytomic-sync

# Test the application
curl -I https://your-polytomic-url.com/status.txt
# Should return HTTP 200

# Check database connectivity
kubectl logs -l app.kubernetes.io/component=web --tail=100 | grep -i "database\|postgres"

# Check Redis connectivity
kubectl logs -l app.kubernetes.io/component=web --tail=100 | grep -i redis
```

## Rollback

If you encounter issues:

```bash
# Rollback to previous version
helm rollback polytomic

# Or reinstall previous chart version
helm install polytomic polytomic/polytomic --version 0.0.18 -f values-old.yaml
```

## Troubleshooting

### Issue: Pods stuck in Pending

**Cause:** Resource limits may be too high for your cluster.

**Solution:** Reduce resource requests:
```yaml
web:
  resources:
    requests:
      cpu: 250m
      memory: 512Mi
```

### Issue: Database connection errors

**Cause:** Incorrect database configuration after migration.

**Solution:** Verify database configuration:
```bash
# Check secret
kubectl get secret polytomic-config -o yaml

# Check environment variables
kubectl exec deployment/polytomic-web -- env | grep DATABASE

# Test database connectivity
kubectl exec deployment/polytomic-web -- psql $DATABASE_URL -c "SELECT 1"
```

### Issue: Volume mount errors

**Cause:** Shared volume configuration incorrect.

**Solution:** Check PVC status:
```bash
kubectl get pvc polytomic-shared
kubectl describe pvc polytomic-shared

# Check if using correct storage class
kubectl get storageclass
```

### Issue: Image pull errors

**Cause:** Empty image tag defaults to Chart.appVersion.

**Solution:** Specify explicit image tag:
```yaml
image:
  tag: "rel2024.11.04"  # Use a specific version
```

## Support

If you encounter issues during the upgrade:

1. Check the [troubleshooting section](#troubleshooting) above
2. Review Helm chart values: `helm get values polytomic`
3. Check pod logs: `kubectl logs -l app.kubernetes.io/name=polytomic`
4. Contact Polytomic support with:
   - Current chart version
   - Target chart version
   - Error messages from pods
   - Database configuration (without credentials)

## What's New in v1.0.0

Beyond breaking changes, v1.0.0 includes many improvements:

- ✅ NetworkPolicy support for enhanced security
- ✅ PodDisruptionBudget templates for high availability
- ✅ Improved health probes with configurable settings
- ✅ Checksum annotations for automatic config rollouts
- ✅ Enhanced NOTES.txt with deployment information
- ✅ values.schema.json for configuration validation
- ✅ Kubernetes 1.24+ minimum version requirement
- ✅ Production-ready default resource limits
- ✅ Autoscaling enabled by default for web/sync

## Next Steps

After successfully upgrading to v1.0.0:

1. **Enable Production Features:**
   ```yaml
   networkPolicy:
     enabled: true
   podDisruptionBudget:
     enabled: true
     minAvailable: 1
   ```

2. **Configure External Databases:** Migrate from embedded to managed databases (RDS, ElastiCache) for production.

3. **Set Up Monitoring:** Configure metrics and tracing:
   ```yaml
   polytomic:
     metrics: true
     tracing: true
   ```

4. **Review Security:** Configure proper authentication methods and remove single-player mode.

5. **Plan for v1.1.0:** Future releases will add optional observability (Loki, Grafana, Prometheus) and additional features.
