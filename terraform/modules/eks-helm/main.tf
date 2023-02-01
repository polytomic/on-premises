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
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":443}]'
    alb.ingress.kubernetes.io/certificate-arn: '${var.certificate_arn}'
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

  cache:
    storage_class: efs-sc

redis:
  enabled: false

postgresql:
  enabled: false

nfs-server-provisioner:
  enabled: false

EOF
  ]

}

