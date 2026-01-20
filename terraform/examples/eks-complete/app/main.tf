locals {
  region                         = "us-west-2"
  prefix                         = "polytomic"
  url                            = "polytomic.${local.domain}"
  domain                         = "example.com"
  polytomic_deployment           = "deployment"
  polytomic_deployment_key       = "key"
  polytomic_image                = "568237466542.dkr.ecr.us-west-2.amazonaws.com/polytomic-onprem"
  polytomic_image_tag            = "latest"
  polytomic_root_user            = "user@example.com"
  polytomic_api_key              = ""  # Optional: Polytomic API key
  polytomic_google_client_id     = "google-client-id"
  polytomic_google_client_secret = "google-client-secret"
}


data "terraform_remote_state" "eks" {
  backend = "local"

  config = {
    path = "../cluster/terraform.tfstate"
  }
}

data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

provider "aws" {
  region = local.region
}


provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}


module "addons" {
  source = "github.com/polytomic/on-premises/terraform/modules/eks-addons"

  prefix            = local.prefix
  region            = local.region
  cluster_name      = data.terraform_remote_state.eks.outputs.cluster_name
  vpc_id            = data.terraform_remote_state.eks.outputs.vpc_id
  oidc_provider_arn = data.terraform_remote_state.eks.outputs.oidc_provider_arn
  efs_id            = data.terraform_remote_state.eks.outputs.filesystem_id

}

module "eks_helm" {
  source = "github.com/polytomic/on-premises/terraform/modules/eks-helm"

  certificate_arn                    = aws_acm_certificate.cert.arn
  subnets                            = join(",", data.terraform_remote_state.eks.outputs.public_subnets)
  polytomic_url                      = local.url
  polytomic_deployment               = local.polytomic_deployment
  polytomic_deployment_key           = local.polytomic_deployment_key
  polytomic_api_key                  = local.polytomic_api_key
  polytomic_image                    = local.polytomic_image
  polytomic_image_tag                = local.polytomic_image_tag
  polytomic_root_user                = local.polytomic_root_user
  redis_host                         = data.terraform_remote_state.eks.outputs.redis_host
  redis_port                         = data.terraform_remote_state.eks.outputs.redis_port
  redis_password                     = data.terraform_remote_state.eks.outputs.redis_auth_string
  postgres_host                      = data.terraform_remote_state.eks.outputs.postgres_host
  postgres_password                  = data.terraform_remote_state.eks.outputs.postgres_password
  polytomic_google_client_id         = local.polytomic_google_client_id
  polytomic_google_client_secret     = local.polytomic_google_client_secret
  polytomic_bucket                   = data.terraform_remote_state.eks.outputs.bucket
  polytomic_bucket_region            = local.region
  efs_id                             = data.terraform_remote_state.eks.outputs.filesystem_id
  polytomic_service_account_role_arn = module.addons.polytomic_role_arn

  depends_on = [
    module.addons
  ]

}

resource "aws_acm_certificate" "cert" {
  domain_name       = local.url
  validation_method = "DNS"
}

data "aws_route53_zone" "zone" {
  name = local.domain
}

resource "aws_route53_record" "record" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.zone.zone_id
}

resource "aws_acm_certificate_validation" "validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.record : record.fqdn]
}
