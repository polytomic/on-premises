locals {
  project_id = ""
  region     = ""

  url                      = ""
  polytomic_deployment     = ""
  polytomic_deployment_key = ""

  polytomic_image     = ""
  polytomic_image_tag = ""

  polytomic_root_user            = ""
  polytomic_google_client_id     = ""
  polytomic_google_client_secret = ""
}


terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }

    helm = {
      source = "hashicorp/helm"
    }
  }
}

provider "google" {
  project = local.project_id
  region  = local.region
}

provider "helm" {
  kubernetes {
    host                   = module.gke.cluster_endpoint
    token                  = module.gke.cluster_token
    cluster_ca_certificate = module.gke.cluster_ca_certificate
  }
}


module "gke_cluster_service_account" {
  source     = "../../modules/gke-cluster-sa"
  project_id = local.project_id
}


module "gke" {
  source = "../../modules/gke"

  project_id = local.project_id
  region     = local.region

  cluster_service_account = module.gke_cluster_service_account.email

}

module "gke_helm" {
  source = "../../modules/gke-helm"

  polytomic_cert_name = google_compute_managed_ssl_certificate.cert.name
  polytomic_ip_name   = module.gke.lb_name

  polytomic_url                  = local.url
  polytomic_deployment           = local.polytomic_deployment
  polytomic_deployment_key       = local.polytomic_deployment_key
  polytomic_image                = local.polytomic_image
  polytomic_image_tag            = local.polytomic_image_tag
  polytomic_root_user            = local.polytomic_root_user
  polytomic_google_client_id     = local.polytomic_google_client_id
  polytomic_google_client_secret = local.polytomic_google_client_secret

  redis_host     = module.gke.redis_host[0]
  redis_port     = module.gke.redis_port[0]
  redis_password = module.gke.redis_auth_string[0]

  postgres_host     = module.gke.postgres_ip[0]
  postgres_password = module.gke.postgres_password[0]

}

resource "google_compute_managed_ssl_certificate" "cert" {
  name    = "polytomic-cert2"
  project = local.project_id

  managed {
    domains = ["${local.url}."]
  }
}
