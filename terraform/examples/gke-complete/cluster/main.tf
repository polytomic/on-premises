locals {
  project_id = ""
  region     = "us-east1"
}

provider "google" {
  project = local.project_id
  region  = local.region
}


module "gke_cluster_service_account" {
  source = "github.com/polytomic/on-premises/terraform/modules/gke-cluster-sa"

  project_id = local.project_id
}

module "gke" {
  source = "github.com/polytomic/on-premises/terraform/modules/gke"

  project_id              = local.project_id
  region                  = local.region
  cluster_service_account = module.gke_cluster_service_account.email

}
