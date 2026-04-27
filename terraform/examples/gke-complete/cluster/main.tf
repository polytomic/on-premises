locals {
  project_id  = ""
  region      = "us-east1"
  prefix      = "polytomic"
  bucket_name = "set-a-globally-unique-bucket-name"

  # The hostname for the Polytomic deployment. The cluster module provisions
  # a Google-managed SSL certificate for this domain. After apply, point a
  # DNS A record at the load_balancer_ip output and wait up to ~60 minutes
  # for the cert to provision.
  polytomic_url = "polytomic.example.com"

  # Optional: separate hostname for the MCP server. When set, the cluster
  # module provisions a second static IP and managed SSL certificate.
  # polytomic_mcp_url = "mcp.polytomic.example.com"

  # IMPORTANT: GCS bucket name must be globally unique
  # Recommended format: "<company>-polytomic-operations"
}

check "bucket_name_configured" {
  assert        = local.bucket_name != "set-a-globally-unique-bucket-name"
  error_message = "Set local.bucket_name to a globally unique GCS bucket name before applying this example."
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
  prefix                  = local.prefix
  cluster_service_account = module.gke_cluster_service_account.email
  workload_identity_sa    = module.gke_cluster_service_account.workload_identity_user_sa_email

  bucket_name = local.bucket_name

  polytomic_url = local.polytomic_url
  # polytomic_mcp_url = local.polytomic_mcp_url

  # Optional: bring your own SSL cert instead of provisioning Google-managed certs.
  # create_managed_certificate = false

  # Optional: customize node pool sizing
  # instance_type = "e2-standard-4"
  # min_size      = 2
  # max_size      = 4
  # desired_size  = 3

  # Optional: customize database
  # database_version     = "POSTGRES_17"
  # postgres_instance_tier = "db-custom-2-7680"
}
