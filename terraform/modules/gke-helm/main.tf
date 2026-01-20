resource "helm_release" "polytomic" {
  name       = "polytomic"
  namespace  = "polytomic"
  repository = "https://charts.polytomic.com"
  chart      = "polytomic"

  create_namespace = true
  wait             = false


  values = [<<EOF
ingress:
  enabled: true
  className: gce
  annotations:
    kubernetes.io/ingress.class:  gce
    ingress.gcp.kubernetes.io/pre-shared-cert: '${var.polytomic_cert_name}'
    kubernetes.io/ingress.global-static-ip-name: '${var.polytomic_ip_name}'

  hosts:
  - host: ${var.polytomic_url}
    paths:
      - path: /*
        pathType: ImplementationSpecific

image:
  repository: ${var.polytomic_image}
  tag: ${var.polytomic_image_tag}

serviceAccount:
  annotations:
    iam.gke.io/gcp-service-account: ${var.polytomic_service_account}

polytomic:
  deployment:
    name: ${var.polytomic_deployment}
    key: ${var.polytomic_deployment_key}
    api_key: ${var.polytomic_api_key}

  auth:
    methods:
      - google
      - microsoft
      - sso
    root_user: ${var.polytomic_root_user}
    url: https://${var.polytomic_url}
    single_player: false
    google_client_id: ${var.polytomic_google_client_id}
    google_client_secret: ${var.polytomic_google_client_secret}

  s3:
    operational_bucket: gs://${var.polytomic_bucket}
    region: ""
    gcs: true

  jobs:
    image: ${var.polytomic_image}

  internal_execution_logs: true

  sharedVolume:
    enabled: true
    mode: dynamic
    size: 20Gi

# Disable embedded databases - use external Cloud SQL and MemoryStore
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

minio:
  enabled: false

nfs-server-provisioner:
  enabled: false

EOF
  ]

}

