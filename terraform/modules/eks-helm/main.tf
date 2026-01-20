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
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: 'ip'
    alb.ingress.kubernetes.io/subnets: "${var.subnets}"
    alb.ingress.kubernetes.io/listen-ports: '${var.certificate_arn != "" ? "[{\"HTTPS\":443}]" : "[{\"HTTP\":80}]"}'
    ${var.certificate_arn != "" ? "alb.ingress.kubernetes.io/certificate-arn: '${var.certificate_arn}'" : "# certificate-arn not configured - using HTTP only"}
    alb.ingress.kubernetes.io/ip-address-type: ipv4
    alb.ingress.kubernetes.io/inbound-cidrs: 0.0.0.0/0

  hosts:
  - host: ${var.polytomic_url}
    paths:
      - path: /*
        pathType: ImplementationSpecific

image:
  repository: ${var.polytomic_image}
  tag: ${var.polytomic_image_tag}

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
    operational_bucket: "s3://${var.polytomic_bucket}"
    region: "${var.polytomic_bucket_region}"

  jobs:
    image: ${var.polytomic_image}

  sharedVolume:
    enabled: true
    mode: static
    size: 10Gi
    static:
      driver: efs.csi.aws.com
      volumeHandle: ${var.efs_id}

# Disable embedded databases - use external RDS and ElastiCache
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

nfs-server-provisioner:
  enabled: false

minio:
  enabled: false

serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: ${var.polytomic_service_account_role_arn}
    eks.amazonaws.com/sts-regional-endpoints: "true"
EOF
  ]

}

