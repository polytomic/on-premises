locals {
  region = "us-east-2"
  prefix = "polytomic-testing"

  # The domain/hostname where Polytomic will be accessed
  # This is used for:
  #   1. Kubernetes Ingress host configuration
  #   2. Polytomic's internal URL settings (OAuth redirects, etc.)
  # After deployment, create a DNS CNAME record pointing this domain to the ALB hostname
  url = "app.polytomic-staging.net"

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
  kubernetes = {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}


module "addons" {
  source = "../../../modules/eks-addons"

  prefix            = local.prefix
  region            = local.region
  cluster_name      = data.terraform_remote_state.eks.outputs.cluster_name
  vpc_id            = data.terraform_remote_state.eks.outputs.vpc_id
  oidc_provider_arn = data.terraform_remote_state.eks.outputs.oidc_provider_arn
}

module "eks_helm" {
  source = "../../../modules/eks-helm"

  # Certificate ARN is optional. When omitted, the ALB will listen on HTTP (port 80) only.
  # Options for handling TLS:
  # 1. Provide an existing ACM certificate ARN (e.g., from another AWS account or manually validated)
  # 2. Use an external load balancer or CDN (CloudFlare, CloudFront, etc.) for TLS termination
  # 3. Create an ACM certificate here and manually validate DNS records in your DNS provider
  #
  # Example with certificate:
  # certificate_arn = "arn:aws:acm:us-east-2:123456789:certificate/your-cert-id"

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

# After deployment, get the ALB DNS name with:
# kubectl get ingress -n polytomic polytomic -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
#
# Then create a CNAME record in your DNS provider pointing your domain to the ALB DNS name.
#
# For TLS, you can:
# - Use CloudFlare or another CDN for TLS termination
# - Create an ACM certificate with manual DNS validation (see example below)
# - Use an external load balancer
#
# Example: ACM certificate with manual DNS validation
# Uncomment and configure the following to create a certificate:
#
# resource "aws_acm_certificate" "cert" {
#   domain_name       = local.url
#   validation_method = "DNS"
#
#   lifecycle {
#     create_before_destroy = true
#   }
# }
#
# After applying, get the validation records:
# aws acm describe-certificate --certificate-arn $(terraform output -raw certificate_arn)
#
# Add the CNAME validation records to your DNS provider, then pass the certificate ARN
# to the eks_helm module above using:
# certificate_arn = aws_acm_certificate.cert.arn
