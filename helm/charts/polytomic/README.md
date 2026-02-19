# polytomic

Polytomic helm chart for kubernetes

![Version: 1.0.2](https://img.shields.io/badge/Version-1.0.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: latest](https://img.shields.io/badge/AppVersion-latest-informational?style=flat-square)

## Installing the Chart

To install the chart with the release name `polytomic`:

```console
git clone https://github.com/polytomic/on-premises.git
cd on-premises
helm install helm/charts/polytomic polytomic
```

## Requirements

Kubernetes: `>=1.34.0-0`

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | postgresql | 18.2.3 |
| https://charts.bitnami.com/bitnami | redis | 24.1.2 |
| https://kubernetes-sigs.github.io/nfs-ganesha-server-and-external-provisioner/ | nfs-server-provisioner | 1.6.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| dev.affinity | object | `{}` |  |
| dev.enabled | bool | `false` |  |
| dev.nodeSelector | object | `{}` |  |
| dev.podAnnotations | object | `{}` |  |
| dev.podSecurityContext.fsGroup | int | `2000` |  |
| dev.resources.limits.cpu | string | `"500m"` |  |
| dev.resources.limits.memory | string | `"1Gi"` |  |
| dev.resources.requests.cpu | string | `"100m"` |  |
| dev.resources.requests.memory | string | `"256Mi"` |  |
| dev.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| dev.securityContext.readOnlyRootFilesystem | bool | `false` |  |
| dev.securityContext.runAsNonRoot | bool | `false` |  |
| dev.securityContext.runAsUser | int | `0` |  |
| dev.tolerations | list | `[]` |  |
| development | bool | `false` |  |
| externalPostgresql.autoMigrate | bool | `true` | Auto-run database migrations on startup |
| externalPostgresql.database | string | `"polytomic"` | Database name |
| externalPostgresql.existingSecret | object | `{"key":"postgresql-password","name":""}` | Use existing secret for password (optional) If set, password field above is ignored |
| externalPostgresql.host | string | `""` | External PostgreSQL host (required if postgresql.enabled=false) |
| externalPostgresql.idleTimeout | string | `"5s"` | Idle timeout |
| externalPostgresql.password | string | `""` | Database password (consider using existing secret) |
| externalPostgresql.poolSize | string | `"15"` | Connection pool size |
| externalPostgresql.port | int | `5432` | External PostgreSQL port |
| externalPostgresql.ssl | bool | `false` | Enable SSL/TLS |
| externalPostgresql.sslMode | string | `"disable"` | SSL mode (disable, require, verify-ca, verify-full) |
| externalPostgresql.username | string | `"polytomic"` | Database username |
| externalRedis.existingSecret | object | `{"key":"redis-password","name":""}` | Use existing secret for password (optional) If set, password field above is ignored |
| externalRedis.host | string | `""` | External Redis host (required if redis.enabled=false) |
| externalRedis.password | string | `""` | Redis password (consider using existing secret) |
| externalRedis.poolSize | int | `0` | Connection pool size (0 = unlimited) |
| externalRedis.port | int | `6379` | External Redis port |
| externalRedis.ssl | bool | `false` | Enable SSL/TLS |
| fullnameOverride | string | `""` |  |
| healthProbes | object | `{"livenessProbe":{"failureThreshold":3,"initialDelaySeconds":30,"periodSeconds":10,"timeoutSeconds":5},"readinessProbe":{"failureThreshold":3,"initialDelaySeconds":30,"periodSeconds":10,"timeoutSeconds":5}}` | Global health probe configuration |
| healthcheck.affinity | object | `{}` |  |
| healthcheck.nodeSelector | object | `{}` |  |
| healthcheck.podAnnotations | object | `{}` |  |
| healthcheck.podSecurityContext.fsGroup | int | `2000` |  |
| healthcheck.resources.limits.cpu | string | `"100m"` |  |
| healthcheck.resources.limits.memory | string | `"256Mi"` |  |
| healthcheck.resources.requests.cpu | string | `"50m"` |  |
| healthcheck.resources.requests.memory | string | `"128Mi"` |  |
| healthcheck.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| healthcheck.securityContext.readOnlyRootFilesystem | bool | `false` |  |
| healthcheck.securityContext.runAsNonRoot | bool | `false` |  |
| healthcheck.securityContext.runAsUser | int | `0` |  |
| healthcheck.sidecarContainers | list | `[]` |  |
| healthcheck.tolerations | list | `[]` |  |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.repository | string | `"568237466542.dkr.ecr.us-west-2.amazonaws.com/polytomic-onprem"` | Image repository |
| image.tag | string | `""` | Image tag. Defaults to Chart.appVersion if not specified. For production, always specify a concrete version (e.g., "rel2021.11.04") See https://docs.polytomic.com/changelog for available versions |
| imagePullSecrets | list | `[]` | Reference to one or more secrets to be used when pulling images Used both for chart-managed pods and passed to Polytomic for dynamically created job pods Example: imagePullSecrets:   - name: polytomic-ecr |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `"nginx"` | Name of the ingress class to route through this controller |
| ingress.enabled | bool | `true` |  |
| ingress.hosts[0].host | string | `"localhost"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| ingress.tls | list | `[]` |  |
| jobworker.affinity | object | `{}` |  |
| jobworker.nodeSelector | object | `{}` |  |
| jobworker.podAnnotations | object | `{}` |  |
| jobworker.podSecurityContext.fsGroup | int | `2000` |  |
| jobworker.resources.limits.cpu | string | `"1000m"` |  |
| jobworker.resources.limits.memory | string | `"2Gi"` |  |
| jobworker.resources.requests.cpu | string | `"500m"` |  |
| jobworker.resources.requests.memory | string | `"1Gi"` |  |
| jobworker.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| jobworker.securityContext.readOnlyRootFilesystem | bool | `false` |  |
| jobworker.securityContext.runAsNonRoot | bool | `false` |  |
| jobworker.securityContext.runAsUser | int | `0` |  |
| jobworker.sidecarContainers | list | `[]` |  |
| jobworker.tolerations | list | `[]` |  |
| minio.enabled | bool | `false` |  |
| minio.mode | string | `"standalone"` |  |
| minio.persistence.size | string | `"50Mi"` |  |
| minio.rootPassword | string | `"polytomic"` |  |
| minio.rootUser | string | `"polytomic"` |  |
| nameOverride | string | `""` |  |
| networkPolicy.allowExternalHttps | bool | `true` |  |
| networkPolicy.enabled | bool | `false` |  |
| networkPolicy.externalHttpsCidrs | list | `[]` |  |
| networkPolicy.ingressNamespaceSelector.name | string | `"ingress-nginx"` |  |
| networkPolicy.postgresql.namespaceSelector."kubernetes.io/metadata.name" | string | `"default"` |  |
| networkPolicy.postgresql.podSelector."app.kubernetes.io/name" | string | `"postgresql"` |  |
| networkPolicy.redis.namespaceSelector."kubernetes.io/metadata.name" | string | `"default"` |  |
| networkPolicy.redis.podSelector."app.kubernetes.io/name" | string | `"redis"` |  |
| nfs-server-provisioner.enabled | bool | `true` |  |
| nfs-server-provisioner.image.repository | string | `"registry.k8s.io/sig-storage/nfs-provisioner"` |  |
| nfs-server-provisioner.image.tag | string | `"v4.0.8"` |  |
| nfs-server-provisioner.persistence.enabled | bool | `true` |  |
| nfs-server-provisioner.storageClass.allowVolumeExpansion | bool | `true` |  |
| nfs-server-provisioner.storageClass.create | bool | `true` |  |
| nfs-server-provisioner.storageClass.defaultClass | bool | `false` |  |
| nfs-server-provisioner.storageClass.name | string | `"nfs"` |  |
| nfs-server-provisioner.storageClass.parameters | object | `{}` |  |
| podDisruptionBudget.enabled | bool | `false` |  |
| podDisruptionBudget.minAvailable | int | `1` |  |
| polytomic.airtable_client_secret | string | `""` |  |
| polytomic.asana_client_id | string | `""` |  |
| polytomic.asana_client_secret | string | `""` |  |
| polytomic.auth.google_client_id | string | `""` | Google OAuth Client ID, obtained by creating a OAuth 2.0 Client ID |
| polytomic.auth.google_client_secret | string | `""` | Google OAuth Client Secret, obtained by creating a OAuth 2.0 Client ID |
| polytomic.auth.methods | list | `[]` |  |
| polytomic.auth.root_user | string | `"user@example.com"` |  |
| polytomic.auth.single_player | bool | `true` | Single player mode If true, no authentication will be required |
| polytomic.auth.url | string | `"https://polytomic.mycompany.com"` | Base URL for accessing Polytomic; for example, https://polytomic.mycompany.com. This will be used when redirecting back from Google and other integrations after authenticating with OAuth. |
| polytomic.auth.workos_api_key | string | `""` |  |
| polytomic.auth.workos_client_id | string | `""` |  |
| polytomic.bingads_client_id | string | `""` |  |
| polytomic.bingads_client_secret | string | `""` |  |
| polytomic.bingads_developer_token | string | `""` |  |
| polytomic.ccloud_api_key | string | `""` |  |
| polytomic.ccloud_api_secret | string | `""` |  |
| polytomic.default_org_features | list | `[]` |  |
| polytomic.deployment.api_key | string | `""` | The global api key for your deployment, user provided. |
| polytomic.deployment.key | string | `""` | The license key for your deployment, provided by Polytomic. |
| polytomic.deployment.name | string | `""` | A unique identifier for your on premises deploy, provided by Polytomic. |
| polytomic.env | string | `""` |  |
| polytomic.fb_login_configuration_id | string | `""` |  |
| polytomic.fbaudience_client_id | string | `""` |  |
| polytomic.fbaudience_client_secret | string | `""` |  |
| polytomic.field_change_tracking | bool | `true` |  |
| polytomic.front_client_id | string | `""` |  |
| polytomic.front_client_secret | string | `""` |  |
| polytomic.github_client_id | string | `""` |  |
| polytomic.github_client_secret | string | `""` |  |
| polytomic.github_deploy_key | string | `""` |  |
| polytomic.googleads_client_id | string | `""` |  |
| polytomic.googleads_client_secret | string | `""` |  |
| polytomic.googleads_developer_token | string | `""` |  |
| polytomic.googlesearchconsole_client_id | string | `""` |  |
| polytomic.googlesearchconsole_client_secret | string | `""` |  |
| polytomic.googleworkspace_client_id | string | `""` |  |
| polytomic.googleworkspace_client_secret | string | `""` |  |
| polytomic.gsheets_api_key | string | `""` |  |
| polytomic.gsheets_app_id | string | `""` |  |
| polytomic.gsheets_client_id | string | `""` |  |
| polytomic.gsheets_client_secret | string | `""` |  |
| polytomic.hubspot_client_id | string | `""` |  |
| polytomic.hubspot_client_secret | string | `""` |  |
| polytomic.intercom_client_id | string | `""` |  |
| polytomic.intercom_client_secret | string | `""` |  |
| polytomic.internal_execution_logs | bool | `false` |  |
| polytomic.linkedinads_client_id | string | `""` |  |
| polytomic.linkedinads_client_secret | string | `""` |  |
| polytomic.log_level | string | `"info"` |  |
| polytomic.metrics | bool | `false` | Telemetry |
| polytomic.outreach_client_id | string | `""` |  |
| polytomic.outreach_client_secret | string | `""` |  |
| polytomic.pardot_client_id | string | `""` |  |
| polytomic.pardot_client_secret | string | `""` |  |
| polytomic.query_workers | int | `10` |  |
| polytomic.roles | object | `{"bulk":{"cleanup_delay_seconds":0,"cpu":0,"database_pool_size":0,"memory_maximum":0,"memory_mega":0,"memory_reservation":0,"redis_pool_size":0,"tags":""},"ingest":{"cleanup_delay_seconds":0,"cpu":0,"database_pool_size":0,"memory_maximum":0,"memory_mega":0,"memory_reservation":0,"redis_pool_size":0,"tags":""},"proxy":{"cleanup_delay_seconds":0,"cpu":0,"database_pool_size":0,"memory_maximum":0,"memory_mega":0,"memory_reservation":0,"redis_pool_size":0,"tags":""},"scheduler":{"cleanup_delay_seconds":0,"cpu":0,"database_pool_size":0,"memory_maximum":0,"memory_mega":0,"memory_reservation":0,"redis_pool_size":0,"tags":""},"task":{"cleanup_delay_seconds":10,"cpu":0,"database_pool_size":0,"memory_maximum":0,"memory_mega":0,"memory_reservation":0,"redis_pool_size":0,"tags":""}}` | Per-role executor configuration. Fields map to the {prefix}_* environment variables read by the application. Prefixes: task → TASK_EXECUTOR, bulk → BULK_EXECUTOR, ingest → INGEST_EXECUTOR,           proxy → PROXY_EXECUTOR, scheduler → SCHEDULER_ROLE.  The task role is the base: any field left at 0/"" in bulk/ingest/proxy/scheduler will inherit the corresponding task value at runtime (setDefaultRoleConfig). Only override the other roles when you need role-specific values. |
| polytomic.roles.task.cleanup_delay_seconds | int | `10` | Seconds to sleep after task completion before cleaning up |
| polytomic.s3.access_key_id | string | `""` | Access key ID |
| polytomic.s3.operational_bucket | string | `"s3://operations"` |  |
| polytomic.s3.region | string | `"us-east-1"` | S3 region e.g. us-east-1 |
| polytomic.s3.secret_access_key | string | `""` | Secret access key |
| polytomic.salesforce_client_id | string | `""` |  |
| polytomic.salesforce_client_secret | string | `""` |  |
| polytomic.sharedVolume.accessModes | list | `["ReadWriteMany"]` | Access modes |
| polytomic.sharedVolume.dynamic.storageClassName | string | `""` | Storage class name (empty = cluster default) |
| polytomic.sharedVolume.enabled | bool | `true` | Enable shared volume (if false, uses emptyDir) |
| polytomic.sharedVolume.mode | string | `"dynamic"` | Provisioning mode: "dynamic" (StorageClass), "static" (pre-existing PV), or "emptyDir" |
| polytomic.sharedVolume.mountPath | string | `"/var/polytomic"` | Mount path in containers |
| polytomic.sharedVolume.size | string | `"20Gi"` | Volume size |
| polytomic.sharedVolume.static.driver | string | `"efs.csi.aws.com"` | CSI driver (e.g., efs.csi.aws.com, nfs.csi.k8s.io) |
| polytomic.sharedVolume.static.volumeAttributes | object | `{}` | Optional volume attributes for CSI driver |
| polytomic.sharedVolume.static.volumeHandle | string | `""` | Volume handle (e.g., EFS filesystem ID: fs-12345678) |
| polytomic.sharedVolume.subPath | string | `""` | Optional subPath within the volume |
| polytomic.sharedVolume.volumeName | string | `"polytomic-shared"` | Volume name for PV/PVC |
| polytomic.shipbob_client_id | string | `""` |  |
| polytomic.shipbob_client_secret | string | `""` |  |
| polytomic.shopify_client_id | string | `""` |  |
| polytomic.shopify_client_secret | string | `""` |  |
| polytomic.smartsheet_client_id | string | `""` |  |
| polytomic.smartsheet_client_secret | string | `""` |  |
| polytomic.stripe_secret_key | string | `""` |  |
| polytomic.sync_retry_errors | bool | `true` |  |
| polytomic.sync_workers | int | `10` |  |
| polytomic.tracing | bool | `false` |  |
| polytomic.tx_buffer_size | int | `1000` |  |
| polytomic.zendesk_client_id | string | `""` |  |
| polytomic.zendesk_client_secret | string | `""` |  |
| postgresql.auth.database | string | `"polytomic"` |  |
| postgresql.auth.password | string | `"polytomic"` |  |
| postgresql.auth.username | string | `"polytomic"` |  |
| postgresql.enabled | bool | `true` |  |
| postgresql.primary.persistence.enabled | bool | `true` |  |
| postgresql.primary.persistence.size | string | `"8Gi"` |  |
| redis.architecture | string | `"standalone"` |  |
| redis.auth.enabled | bool | `true` |  |
| redis.auth.password | string | `"polytomic"` |  |
| redis.enabled | bool | `true` |  |
| redis.master.persistence.enabled | bool | `true` |  |
| redis.master.persistence.size | string | `"8Gi"` |  |
| scheduler.affinity | object | `{}` |  |
| scheduler.nodeSelector | object | `{}` |  |
| scheduler.podAnnotations | object | `{}` |  |
| scheduler.podSecurityContext.fsGroup | int | `2000` |  |
| scheduler.resources.limits.cpu | string | `"500m"` |  |
| scheduler.resources.limits.memory | string | `"1Gi"` |  |
| scheduler.resources.requests.cpu | string | `"250m"` |  |
| scheduler.resources.requests.memory | string | `"512Mi"` |  |
| scheduler.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| scheduler.securityContext.readOnlyRootFilesystem | bool | `false` |  |
| scheduler.securityContext.runAsNonRoot | bool | `false` |  |
| scheduler.securityContext.runAsUser | int | `0` |  |
| scheduler.sidecarContainers | list | `[]` |  |
| scheduler.tolerations | list | `[]` |  |
| schemacache.affinity | object | `{}` |  |
| schemacache.nodeSelector | object | `{}` |  |
| schemacache.podAnnotations | object | `{}` |  |
| schemacache.podSecurityContext.fsGroup | int | `2000` |  |
| schemacache.resources.limits.cpu | string | `"500m"` |  |
| schemacache.resources.limits.memory | string | `"1Gi"` |  |
| schemacache.resources.requests.cpu | string | `"250m"` |  |
| schemacache.resources.requests.memory | string | `"512Mi"` |  |
| schemacache.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| schemacache.securityContext.readOnlyRootFilesystem | bool | `false` |  |
| schemacache.securityContext.runAsNonRoot | bool | `false` |  |
| schemacache.securityContext.runAsUser | int | `0` |  |
| schemacache.sidecarContainers | list | `[]` |  |
| schemacache.tolerations | list | `[]` |  |
| secret.name | string | `""` |  |
| service.port | int | `80` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| sync.affinity | object | `{}` |  |
| sync.autoscaling.enabled | bool | `true` |  |
| sync.autoscaling.maxReplicas | int | `10` |  |
| sync.autoscaling.minReplicas | int | `2` |  |
| sync.autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| sync.autoscaling.targetMemoryUtilizationPercentage | int | `80` |  |
| sync.nodeSelector | object | `{}` |  |
| sync.podAnnotations | object | `{}` |  |
| sync.podSecurityContext.fsGroup | int | `2000` |  |
| sync.replicaCount | int | `2` |  |
| sync.resources.limits.cpu | string | `"1000m"` |  |
| sync.resources.limits.memory | string | `"2Gi"` |  |
| sync.resources.requests.cpu | string | `"500m"` |  |
| sync.resources.requests.memory | string | `"1Gi"` |  |
| sync.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| sync.securityContext.readOnlyRootFilesystem | bool | `false` |  |
| sync.securityContext.runAsNonRoot | bool | `false` |  |
| sync.securityContext.runAsUser | int | `0` |  |
| sync.sidecarContainers | list | `[]` |  |
| sync.tolerations | list | `[]` |  |
| web.affinity | object | `{}` |  |
| web.autoscaling.enabled | bool | `true` |  |
| web.autoscaling.maxReplicas | int | `10` |  |
| web.autoscaling.minReplicas | int | `2` |  |
| web.autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| web.autoscaling.targetMemoryUtilizationPercentage | int | `80` |  |
| web.nodeSelector | object | `{}` |  |
| web.podAnnotations | object | `{}` |  |
| web.podSecurityContext.fsGroup | int | `2000` |  |
| web.replicaCount | int | `2` |  |
| web.resources.limits.cpu | string | `"1000m"` |  |
| web.resources.limits.memory | string | `"2Gi"` |  |
| web.resources.requests.cpu | string | `"500m"` |  |
| web.resources.requests.memory | string | `"1Gi"` |  |
| web.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| web.securityContext.readOnlyRootFilesystem | bool | `false` |  |
| web.securityContext.runAsNonRoot | bool | `false` |  |
| web.securityContext.runAsUser | int | `0` |  |
| web.sidecarContainers | string | `nil` |  |
| web.tolerations | list | `[]` |  |
| worker.affinity | object | `{}` |  |
| worker.autoscaling.enabled | bool | `false` |  |
| worker.autoscaling.maxReplicas | int | `100` |  |
| worker.autoscaling.minReplicas | int | `1` |  |
| worker.autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| worker.autoscaling.targetMemoryUtilizationPercentage | int | `80` |  |
| worker.nodeSelector | object | `{}` |  |
| worker.podAnnotations | object | `{}` |  |
| worker.podSecurityContext.fsGroup | int | `2000` |  |
| worker.replicaCount | int | `2` |  |
| worker.resources.limits.cpu | string | `"500m"` |  |
| worker.resources.limits.memory | string | `"1Gi"` |  |
| worker.resources.requests.cpu | string | `"250m"` |  |
| worker.resources.requests.memory | string | `"512Mi"` |  |
| worker.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| worker.securityContext.readOnlyRootFilesystem | bool | `false` |  |
| worker.securityContext.runAsNonRoot | bool | `false` |  |
| worker.securityContext.runAsUser | int | `0` |  |
| worker.sidecarContainers | list | `[]` |  |
| worker.tolerations | list | `[]` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)