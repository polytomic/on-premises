locals {
  project_id               = "project"
  region                   = "us-east1"
  url                      = "polytomic.example.com"
  polytomic_deployment     = "deployment"
  polytomic_deployment_key = "key"
  polytomic_image          = "us.gcr.io/polytomic-container-distro/polytomic-onprem"
  polytomic_image_tag      = "latest"
  polytomic_root_user      = "user@example.com"
  polytomic_bucket         = "polytomic-bucket"

}


provider "helm" {
  kubernetes {
    host                   = data.google_container_cluster.my_cluster.endpoint
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate)
  }
}

data "terraform_remote_state" "gke" {
  backend = "local"

  config = {
    path = "../cluster/terraform.tfstate"
  }
}

# Retrieve GKE cluster information
provider "google" {
  project = local.project_id
  region  = local.region
}

# Configure kubernetes provider with Oauth2 access token.
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config
# This fetches a new token, which will expire in 1 hour.
data "google_client_config" "default" {}

data "google_container_cluster" "my_cluster" {
  name     = data.terraform_remote_state.gke.outputs.cluster_name
  location = local.region
}



module "gke_helm" {
  source = "github.com/polytomic/on-premises/terraform/modules/gke-helm"

  polytomic_cert_name       = google_compute_managed_ssl_certificate.cert.name
  polytomic_ip_name         = data.terraform_remote_state.gke.outputs.load_balancer_name
  polytomic_url             = local.url
  polytomic_deployment      = local.polytomic_deployment
  polytomic_deployment_key  = local.polytomic_deployment_key
  polytomic_image           = local.polytomic_image
  polytomic_image_tag       = local.polytomic_image_tag
  polytomic_root_user       = local.polytomic_root_user
  redis_host                = data.terraform_remote_state.gke.outputs.redis_host
  redis_port                = data.terraform_remote_state.gke.outputs.redis_port
  redis_password            = data.terraform_remote_state.gke.outputs.redis_auth_string
  postgres_host             = data.terraform_remote_state.gke.outputs.postgres_ip
  postgres_password         = data.terraform_remote_state.gke.outputs.postgres_password
  polytomic_bucket          = local.polytomic_bucket
  polytomic_service_account = data.terraform_remote_state.gke.outputs.workload_identity_user_sa
}

resource "google_compute_managed_ssl_certificate" "cert" {
  name    = "polytomic-cert"
  project = local.project_id

  managed {
    domains = ["${local.url}."]
  }
}
