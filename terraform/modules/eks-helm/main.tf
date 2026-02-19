locals {
  # Determine chart source based on configuration
  use_repository = var.chart_repository != ""
  chart_path     = var.chart_path != "" ? var.chart_path : "${path.module}/../../../helm/charts/polytomic"

  # Use explicit logger tag if provided, otherwise match the main Polytomic image tag
  vector_image_tag = coalesce(var.polytomic_logger_image_tag, var.polytomic_image_tag)
}

resource "helm_release" "polytomic" {
  name              = "polytomic"
  namespace         = "polytomic"
  dependency_update = true
  repository        = local.use_repository ? var.chart_repository : null
  chart             = local.use_repository ? "polytomic" : local.chart_path
  version           = local.use_repository && var.chart_version != "" ? var.chart_version : null

  create_namespace = true
  wait             = false


  values = [<<EOF
imageRegistry: ${var.ecr_registry}

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

  # Vector logging configuration
  internal_execution_logs: ${var.polytomic_use_logger}
  vector:
    daemonset:
      enabled: ${var.polytomic_use_logger}
      image: ${var.polytomic_logger_image}
      tag: ${local.vector_image_tag}
      serviceAccount:
        roleArn: ${var.polytomic_use_logger && var.oidc_provider_arn != "" ? module.vector_role[0].arn : ""}
    managedLogs: ${var.polytomic_managed_logs}

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

# IAM role for Vector DaemonSet (IRSA)
module "vector_role" {
  count   = var.polytomic_use_logger && var.oidc_provider_arn != "" ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "~> 6.0"

  name = "${var.polytomic_deployment}-vector-daemonset"

  policies = {
    policy = aws_iam_policy.vector_s3[0].arn
  }

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["polytomic:polytomic-vector"]
    }
  }
}

resource "aws_iam_policy" "vector_s3" {
  count = var.polytomic_use_logger && var.oidc_provider_arn != "" ? 1 : 0

  name        = "${var.polytomic_deployment}-vector-s3"
  description = "S3 access for Vector DaemonSet to write execution logs"
  policy      = data.aws_iam_policy_document.vector_s3[0].json
}

data "aws_iam_policy_document" "vector_s3" {
  count = var.polytomic_use_logger && var.oidc_provider_arn != "" ? 1 : 0

  statement {
    actions = [
      "s3:PutObject",
    ]
    effect = "Allow"
    resources = [
      var.execution_log_bucket_arn != "" ? "${var.execution_log_bucket_arn}/*" : "arn:aws:s3:::${var.polytomic_bucket}/*"
    ]
  }
}
