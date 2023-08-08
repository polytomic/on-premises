# polytomic

Polytomic helm chart for kubernetes

![Version: 0.0.12](https://img.shields.io/badge/Version-0.0.12-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.0.1](https://img.shields.io/badge/AppVersion-0.0.1-informational?style=flat-square)

## Installing the Chart

To install the chart with the release name `polytomic`:

```console
git clone https://github.com/polytomic/on-premises.git
cd on-premises
helm install helm/charts/polytomic polytomic
```

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | postgresql | 12.1.9 |
| https://charts.bitnami.com/bitnami | redis | 17.4.3 |
| https://kubernetes-sigs.github.io/nfs-ganesha-server-and-external-provisioner/ | nfs-server-provisioner | 1.6.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| dev.affinity | object | `{}` |  |
| dev.nodeSelector | object | `{}` |  |
| dev.podAnnotations | object | `{}` |  |
| dev.podSecurityContext | object | `{}` |  |
| dev.resources | object | `{}` |  |
| dev.securityContext | object | `{}` |  |
| dev.tolerations | list | `[]` |  |
| development | bool | `false` |  |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.repository | string | `"568237466542.dkr.ecr.us-west-2.amazonaws.com/polytomic-onprem"` | Image repository |
| image.tag | string | `"latest"` | Overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` | Reference to one or more secrets to be used when pulling images |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `"nginx"` | Name of the ingress class to route through this controller |
| ingress.enabled | bool | `true` |  |
| ingress.hosts[0].host | string | `"localhost"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| ingress.tls | list | `[]` |  |
| minio.enabled | bool | `false` |  |
| minio.mode | string | `"standalone"` |  |
| minio.persistence.size | string | `"50Mi"` |  |
| minio.rootPassword | string | `"polytomic"` |  |
| minio.rootUser | string | `"polytomic"` |  |
| nameOverride | string | `""` |  |
| nfs-server-provisioner.enabled | bool | `true` |  |
| nfs-server-provisioner.image.repository | string | `"k8s.gcr.io/sig-storage/nfs-provisioner"` |  |
| nfs-server-provisioner.image.tag | string | `"v3.0.1"` |  |
| nfs-server-provisioner.persistence.enabled | bool | `true` |  |
| nfs-server-provisioner.storageClass.allowVolumeExpansion | bool | `true` |  |
| nfs-server-provisioner.storageClass.create | bool | `true` |  |
| nfs-server-provisioner.storageClass.defaultClass | bool | `false` |  |
| nfs-server-provisioner.storageClass.name | string | `"nfs"` |  |
| nfs-server-provisioner.storageClass.parameters | object | `{}` |  |
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
| polytomic.cache.enabled | bool | `true` |  |
| polytomic.cache.size | string | `"20Mi"` |  |
| polytomic.cache.storage_class | string | `""` |  |
| polytomic.cache.volume_name | string | `"polytomic-cache"` |  |
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
| polytomic.linkedinads_client_id | string | `""` |  |
| polytomic.linkedinads_client_secret | string | `""` |  |
| polytomic.log_level | string | `"info"` |  |
| polytomic.metrics | bool | `false` | Telemetry |
| polytomic.outreach_client_id | string | `""` |  |
| polytomic.outreach_client_secret | string | `""` |  |
| polytomic.pardot_client_id | string | `""` |  |
| polytomic.pardot_client_secret | string | `""` |  |
| polytomic.postgres.auto_migrate | bool | `true` |  |
| polytomic.postgres.database | string | `"polytomic"` | Database name |
| polytomic.postgres.host | string | `"polytomic-postgresql"` | Host address |
| polytomic.postgres.password | string | `"polytomic"` | Password for given user |
| polytomic.postgres.port | int | `5432` | Port number |
| polytomic.postgres.ssl | bool | `false` | enable/disable SSL |
| polytomic.postgres.username | string | `"polytomic"` | Postgres user name |
| polytomic.query_workers | int | `10` |  |
| polytomic.redis.host | string | `"polytomic-redis-master"` |  |
| polytomic.redis.password | string | `"polytomic"` |  |
| polytomic.redis.port | int | `6379` |  |
| polytomic.redis.ssl | bool | `false` |  |
| polytomic.redis.username | string | `nil` |  |
| polytomic.s3.access_key_id | string | `""` | Access key ID |
| polytomic.s3.log_bucket | string | `""` | The bucket stores log files containing records involved in a sync execution |
| polytomic.s3.operational_bucket | string | `"s3://operations"` |  |
| polytomic.s3.query_bucket | string | `""` | The bucket is used to store query exports from Polytomic's SQL Runner. |
| polytomic.s3.record_log_bucket | string | `"records"` | Holds record logs for syncs |
| polytomic.s3.region | string | `"us-east-1"` | S3 region e.g. us-east-1 |
| polytomic.s3.secret_access_key | string | `""` | Secret access key |
| polytomic.salesforce_client_id | string | `""` |  |
| polytomic.salesforce_client_secret | string | `""` |  |
| polytomic.shipbob_client_id | string | `""` |  |
| polytomic.shipbob_client_secret | string | `""` |  |
| polytomic.shopify_client_id | string | `""` |  |
| polytomic.shopify_client_secret | string | `""` |  |
| polytomic.smartsheet_client_id | string | `""` |  |
| polytomic.smartsheet_client_secret | string | `""` |  |
| polytomic.stripe_secret_key | string | `""` |  |
| polytomic.sync_retry_errors | bool | `true` |  |
| polytomic.sync_workers | int | `10` |  |
| polytomic.task_executor_cleanup_delay_seconds | int | `10` |  |
| polytomic.tracing | bool | `false` |  |
| polytomic.tx_buffer_size | int | `1000` |  |
| polytomic.zendesk_client_id | string | `""` |  |
| polytomic.zendesk_client_secret | string | `""` |  |
| postgresql.auth.database | string | `"polytomic"` |  |
| postgresql.auth.password | string | `"polytomic"` |  |
| postgresql.auth.username | string | `"polytomic"` |  |
| postgresql.enabled | bool | `true` |  |
| redis.architecture | string | `"standalone"` |  |
| redis.auth.enabled | bool | `true` |  |
| redis.auth.password | string | `"polytomic"` |  |
| redis.enabled | bool | `true` |  |
| secret.name | string | `""` |  |
| service.port | int | `80` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| sync.affinity | object | `{}` |  |
| sync.autoscaling.enabled | bool | `true` |  |
| sync.autoscaling.maxReplicas | int | `100` |  |
| sync.autoscaling.minReplicas | int | `1` |  |
| sync.autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| sync.autoscaling.targetMemoryUtilizationPercentage | int | `80` |  |
| sync.nodeSelector | object | `{}` |  |
| sync.podAnnotations | object | `{}` |  |
| sync.podSecurityContext | object | `{}` |  |
| sync.replicaCount | int | `1` |  |
| sync.resources | object | `{}` |  |
| sync.securityContext | object | `{}` |  |
| sync.sidecarContainers | list | `[]` |  |
| sync.tolerations | list | `[]` |  |
| web.affinity | object | `{}` |  |
| web.autoscaling.enabled | bool | `true` |  |
| web.autoscaling.maxReplicas | int | `100` |  |
| web.autoscaling.minReplicas | int | `1` |  |
| web.autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| web.autoscaling.targetMemoryUtilizationPercentage | int | `80` |  |
| web.nodeSelector | object | `{}` |  |
| web.podAnnotations | object | `{}` |  |
| web.podSecurityContext | object | `{}` |  |
| web.replicaCount | int | `1` |  |
| web.resources | object | `{}` |  |
| web.securityContext | object | `{}` |  |
| web.sidecarContainers | string | `nil` |  |
| web.tolerations | list | `[]` |  |
| worker.affinity | object | `{}` |  |
| worker.autoscaling.enabled | bool | `true` |  |
| worker.autoscaling.maxReplicas | int | `100` |  |
| worker.autoscaling.minReplicas | int | `1` |  |
| worker.autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| worker.autoscaling.targetMemoryUtilizationPercentage | int | `80` |  |
| worker.nodeSelector | object | `{}` |  |
| worker.podAnnotations | object | `{}` |  |
| worker.podSecurityContext | object | `{}` |  |
| worker.replicaCount | int | `1` |  |
| worker.resources | object | `{}` |  |
| worker.securityContext | object | `{}` |  |
| worker.sidecarContainers | list | `[]` |  |
| worker.tolerations | list | `[]` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)