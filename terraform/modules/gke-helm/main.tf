resource "helm_release" "polytomic" {
  name      = "polytomic"
  namespace = "polytomic"
  chart     = "../../../helm/charts/polytomic"

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


polytomic:
  deployment:
    name: ${var.polytomic_deployment}
    key: ${var.polytomic_deployment_key}
  
  auth:
    root_user: ${var.polytomic_root_user}
    url: https://${var.polytomic_url}
    single_player: false
    google_client_id: ${var.polytomic_google_client_id}
    google_client_secret: ${var.polytomic_google_client_secret}

  redis:
    username:
    password: ${var.redis_password}
    host: ${var.redis_host}
    port: ${var.redis_port}

  postgres:
    username: polytomic
    password: ${var.postgres_password}
    host: ${var.postgres_host}
  
  jobs:
    image: ${var.polytomic_image}

redis:
  enabled: false

postgresql:
  enabled: false

EOF
  ]

}

