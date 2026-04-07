locals {
  project_id = "project"
  region     = "us-east1"

  # The domain/hostname where Polytomic will be accessed
  # After deployment, create a DNS A record pointing this domain to the load balancer IP
  url = "polytomic.example.com"

  polytomic_deployment           = "deployment"
  polytomic_deployment_key       = "key"
  polytomic_image_registry       = "us.gcr.io/polytomic-container-distro"
  polytomic_image                = "polytomic-onprem"
  polytomic_image_tag            = "latest"
  polytomic_root_user            = "user@example.com"
  polytomic_google_client_id     = "google-client-id"
  polytomic_google_client_secret = "google-client-secret"
}


provider "helm" {
  kubernetes {
    host                   = "https://${data.google_container_cluster.my_cluster.endpoint}"
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

provider "google" {
  project = local.project_id
  region  = local.region
}

data "google_client_config" "default" {}

data "google_container_cluster" "my_cluster" {
  name     = data.terraform_remote_state.gke.outputs.cluster_name
  location = local.region
}


module "gke_helm" {
  source = "github.com/polytomic/on-premises/terraform/modules/gke-helm"

  polytomic_cert_name            = google_compute_managed_ssl_certificate.cert.name
  polytomic_ip_name              = data.terraform_remote_state.gke.outputs.load_balancer_name
  polytomic_url                  = local.url
  polytomic_deployment           = local.polytomic_deployment
  polytomic_deployment_key       = local.polytomic_deployment_key
  image_registry                 = local.polytomic_image_registry
  polytomic_image                = local.polytomic_image
  polytomic_image_tag            = local.polytomic_image_tag
  polytomic_root_user            = local.polytomic_root_user
  redis_host                     = data.terraform_remote_state.gke.outputs.redis_host
  redis_port                     = data.terraform_remote_state.gke.outputs.redis_port
  redis_password                 = data.terraform_remote_state.gke.outputs.redis_auth_string
  postgres_host                  = data.terraform_remote_state.gke.outputs.postgres_ip
  postgres_password              = data.terraform_remote_state.gke.outputs.postgres_password
  database_name                  = data.terraform_remote_state.gke.outputs.database_name
  database_username              = data.terraform_remote_state.gke.outputs.database_username
  polytomic_bucket               = data.terraform_remote_state.gke.outputs.bucket
  polytomic_service_account      = data.terraform_remote_state.gke.outputs.workload_identity_user_sa
  polytomic_google_client_id     = local.polytomic_google_client_id
  polytomic_google_client_secret = local.polytomic_google_client_secret

  # Vector DaemonSet log collection (enabled by default)
  # By default, the DaemonSet reuses the main workload identity service account.
  # To isolate log writes, set a dedicated logger service account and grant it
  # bucket access in the cluster module via logger_workload_identity_sa:
  # polytomic_logger_service_account = "vector-sa@my-project.iam.gserviceaccount.com"

  # Optional: Forward logs to Polytomic-managed Datadog
  # Requires a deployment key provisioned for managed logging.
  # polytomic_managed_logs = true

  # Optional: Datadog Agent for APM tracing
  # polytomic_use_dd_agent = true

  # Optional: Additional Helm values (takes precedence over module defaults)
  # extra_helm_values = <<-EOT
  #   web:
  #     replicas: 3
  #   worker:
  #     replicas: 3
  # EOT
}

resource "google_compute_managed_ssl_certificate" "cert" {
  name    = "polytomic-cert"
  project = local.project_id

  managed {
    domains = ["${local.url}."]
  }
}

# After deployment:
# 1. Get the load balancer IP from the cluster outputs
# 2. Create a DNS A record pointing your domain to the load balancer IP
# 3. Wait for the managed SSL certificate to be provisioned (can take up to 60 minutes)
