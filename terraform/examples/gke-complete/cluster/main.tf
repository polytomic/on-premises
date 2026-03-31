locals {
  project_id = ""
  region     = "us-east1"
  prefix     = "polytomic"

  # IMPORTANT: GCS bucket name must be globally unique
  # Recommended format: "<company>-polytomic-operations"
  # If not specified, defaults to "${prefix}-operations"
  # bucket_name = "my-company-polytomic-operations"
}

provider "google" {
  project = local.project_id
  region  = local.region
}


module "gke_cluster_service_account" {
  source = "../../../modules/gke-cluster-sa"

  project_id = local.project_id
}

module "gke" {
  source = "../../../modules/gke"

  project_id              = local.project_id
  region                  = local.region
  prefix                  = local.prefix
  cluster_service_account = module.gke_cluster_service_account.email
  workload_identity_sa    = module.gke_cluster_service_account.workload_identity_user_sa_email

  # Uncomment to specify explicit bucket name (otherwise uses "${prefix}-operations")
  # bucket_name = local.bucket_name

  # Optional: customize node pool sizing
  # instance_type = "e2-standard-4"
  # min_size      = 2
  # max_size      = 4
  # desired_size  = 3

  # Optional: customize database
  # database_version     = "POSTGRES_17"
  # postgres_instance_tier = "db-custom-2-7680"
}
