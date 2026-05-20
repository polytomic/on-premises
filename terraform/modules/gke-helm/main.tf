locals {
  # Determine chart source based on configuration
  use_repository = var.chart_repository != ""
  chart_path     = var.chart_path != "" ? var.chart_path : "${path.module}/../../../helm/charts/polytomic"

  # Use explicit logger tag if provided, otherwise match the main Polytomic image tag
  vector_image_tag             = coalesce(var.polytomic_logger_image_tag, var.polytomic_image_tag)
  vector_service_account_email = coalesce(var.polytomic_logger_service_account, var.polytomic_service_account)

  mcp_image_tag = coalesce(var.polytomic_mcp_image_tag, var.polytomic_image_tag)

  main_ingress_has_certificate = var.polytomic_certmap_name != "" || var.polytomic_cert_name != ""
  mcp_ingress_has_certificate  = var.polytomic_mcp_certmap_name != "" || var.polytomic_mcp_cert_name != ""

  # Pick between the legacy compute_managed_ssl_certificate annotation (one
  # cert per ingress, provisioned via HTTP-01 — incurs a 5–60 min wait the
  # first time DNS for the host resolves to the LB) and the Certificate
  # Manager annotation (one cert map shared across many ingresses,
  # validated once via DNS-01 — no per-ingress wait).
  ingress_cert_annotation     = var.polytomic_certmap_name != "" ? "networking.gke.io/certmap: '${var.polytomic_certmap_name}'" : "ingress.gcp.kubernetes.io/pre-shared-cert: '${var.polytomic_cert_name}'"
  mcp_ingress_cert_annotation = var.polytomic_mcp_certmap_name != "" ? "networking.gke.io/certmap: '${var.polytomic_mcp_certmap_name}'" : "ingress.gcp.kubernetes.io/pre-shared-cert: '${var.polytomic_mcp_cert_name}'"
}

resource "helm_release" "polytomic" {
  name              = "polytomic"
  namespace         = "polytomic"
  dependency_update = local.use_repository
  repository        = local.use_repository ? var.chart_repository : null
  chart             = local.use_repository ? "polytomic" : local.chart_path
  version           = local.use_repository && var.chart_version != "" ? var.chart_version : null

  create_namespace = true
  wait             = var.wait
  timeout          = var.wait ? var.timeout : null
  force_update     = var.force_update

  lifecycle {
    precondition {
      condition     = local.main_ingress_has_certificate
      error_message = "Set either polytomic_certmap_name or polytomic_cert_name for the main ingress."
    }

    precondition {
      condition     = !var.polytomic_mcp_ingress_enabled || local.mcp_ingress_has_certificate
      error_message = "When polytomic_mcp_ingress_enabled is true, set either polytomic_mcp_certmap_name or polytomic_mcp_cert_name."
    }
  }


  values = concat([<<EOF
imageRegistry: ${var.image_registry}

ingress:
  enabled: true
  className: gce
  annotations:
    kubernetes.io/ingress.class: gce
    ${local.ingress_cert_annotation}
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

  # Vector logging configuration
  vector:
    daemonset:
      enabled: ${var.polytomic_use_logger}
      image: ${var.polytomic_logger_image}
      tag: ${local.vector_image_tag}
      serviceAccount:
        annotations:
          iam.gke.io/gcp-service-account: ${local.vector_service_account_email}
    managedLogs: ${var.polytomic_managed_logs}

  # Datadog Agent DaemonSet for APM
  datadog:
    daemonset:
      enabled: ${var.polytomic_use_dd_agent}
      image: ${var.polytomic_dd_agent_image}
      tag: ${coalesce(var.polytomic_dd_agent_image_tag, var.polytomic_image_tag)}

  sharedVolume:
    enabled: true
    mode: dynamic
    size: 20Gi
    dynamic:
      storageClassName: nfs

mcp:
  enabled: ${var.polytomic_mcp_enabled}
  replicaCount: ${var.polytomic_mcp_replica_count}
  apiVersion: "${var.polytomic_mcp_api_version}"
  image:
    repository: ${var.polytomic_mcp_image}
    tag: ${local.mcp_image_tag}
  ingress:
    enabled: ${var.polytomic_mcp_ingress_enabled}
    className: gce
    annotations:
      kubernetes.io/ingress.class: gce
      ${local.mcp_ingress_cert_annotation}
      kubernetes.io/ingress.global-static-ip-name: '${var.polytomic_mcp_ip_name}'
    hosts:
      - host: ${var.polytomic_mcp_url}
        paths:
          - path: /*
            pathType: ImplementationSpecific

# Disable embedded databases - use external Cloud SQL and MemoryStore
postgresql:
  enabled: false

redis:
  enabled: false

# Configure external PostgreSQL (Cloud SQL)
externalPostgresql:
  host: ${var.postgres_host}
  port: 5432
  username: ${var.database_username}
  password: ${var.postgres_password}
  database: ${var.database_name}
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
  enabled: true
  persistence:
    size: 25Gi

EOF
  ], var.extra_helm_values != "" ? [trimspace(var.extra_helm_values)] : [])

}
