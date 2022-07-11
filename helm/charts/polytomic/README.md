# Polytomic

Polytomic helm chart for kubernetes

![Version: 0.0.1](https://img.shields.io/badge/Version-0.0.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.0.1](https://img.shields.io/badge/AppVersion-0.0.1-informational?style=flat-square)

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
| https://charts.bitnami.com/bitnami | postgresql | 11.3.0 |
| https://charts.bitnami.com/bitnami | redis | 16.9.11 |
| https://kubernetes-sigs.github.io/nfs-ganesha-server-and-external-provisioner/ | nfs-server-provisioner | 1.4.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
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
| minio.enabled | bool | `true` |  |
| minio.mode | string | `"standalone"` |  |
| minio.persistence.size | string | `"50Mi"` |  |
| minio.rootPassword | string | `"polytomic"` |  |
| minio.rootUser | string | `"polytomic"` |  |
| nameOverride | string | `""` |  |
| nfs-server-provisioner.enabled | bool | `true` |  |
| nfs-server-provisioner.image.repository | string | `"jaken551/nfs-provisioner"` |  |
| nfs-server-provisioner.image.tag | string | `"latest"` |  |
| nfs-server-provisioner.storageClass.allowVolumeExpansion | bool | `true` |  |
| nfs-server-provisioner.storageClass.create | bool | `true` |  |
| nfs-server-provisioner.storageClass.defaultClass | bool | `false` |  |
| nfs-server-provisioner.storageClass.name | string | `"nfs"` |  |
| nfs-server-provisioner.storageClass.parameters | object | `{}` |  |
| polytomic.auth.google_client_id | string | `""` | Google OAuth Client ID, obtained by creating a OAuth 2.0 Client ID |
| polytomic.auth.google_client_secret | string | `""` | Google OAuth Client Secret, obtained by creating a OAuth 2.0 Client ID |
| polytomic.auth.root_user | string | `"user@example.com"` |  |
| polytomic.auth.single_player | bool | `true` | Single player mode If true, no authentication will be required |
| polytomic.auth.url | string | `"https://polytomic.mycompany.com"` | Base URL for accessing Polytomic; for example, https://polytomic.mycompany.com. This will be used when redirecting back from Google and other integrations after authenticating with OAuth. |
| polytomic.cache.enabled | bool | `true` |  |
| polytomic.cache.size | string | `"20Mi"` |  |
| polytomic.cache.volume_name | string | `"polytomic-cache"` |  |
| polytomic.deployment.key | string | `""` | The license key for your deployment, provided by Polytomic. |
| polytomic.deployment.name | string | `""` | A unique identifier for your on premises deploy, provided by Polytomic. |
| polytomic.log_level | string | `"info"` |  |
| polytomic.postgres.database | string | `"polytomic"` | Database name |
| polytomic.postgres.host | string | `"polytomic-postgresql"` | Host address |
| polytomic.postgres.password | string | `"polytomic"` | Password for given user |
| polytomic.postgres.port | int | `5432` | Port number |
| polytomic.postgres.ssl | bool | `false` | enable/disable SSL |
| polytomic.postgres.username | string | `"polytomic"` | Postgres user name |
| polytomic.redis.host | string | `"polytomic-redis-master"` |  |
| polytomic.redis.password | string | `"polytomic"` |  |
| polytomic.redis.port | int | `6379` |  |
| polytomic.redis.ssl | bool | `false` |  |
| polytomic.redis.username | string | `nil` |  |
| polytomic.s3.access_key_id | string | `""` | Access key ID |
| polytomic.s3.log_bucket | string | `"executions"` | The bucket stores log files containing records involved in a sync execution |
| polytomic.s3.query_bucket | string | `"queries"` | The bucket is used to store query exports from Polytomic's SQL Runner. |
| polytomic.s3.region | string | `"us-east-1"` | S3 region e.g. us-east-1 |
| polytomic.s3.secret_access_key | string | `""` | Secret access key |
| postgresql.auth.database | string | `"polytomic"` |  |
| postgresql.auth.password | string | `"polytomic"` |  |
| postgresql.auth.username | string | `"polytomic"` |  |
| postgresql.enabled | bool | `true` |  |
| redis.architecture | string | `"standalone"` |  |
| redis.auth.enabled | bool | `true` |  |
| redis.auth.password | string | `"polytomic"` |  |
| redis.enabled | bool | `true` |  |
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
| worker.tolerations | list | `[]` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)