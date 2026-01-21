locals {
  project_id = ""
  region     = "us-east1"

  # IMPORTANT: GCS bucket name must be globally unique
  # Recommended format: "<company>-polytomic-operations"
  bucket_name = "my-company-polytomic-operations"
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
  bucket_name             = local.bucket_name
  workload_identity_sa    = module.gke_cluster_service_account.workload_identity_user_sa_email
}
