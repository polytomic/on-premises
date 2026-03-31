module "gcp_network" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 12.0"
  project_id   = var.project_id
  network_name = var.prefix

  subnets = [
    {
      subnet_name   = var.prefix
      subnet_ip     = "10.10.0.0/16"
      subnet_region = var.region
    },
  ]

  secondary_ranges = {
    "${var.prefix}" = [
      {
        range_name    = var.ip_range_pods_name
        ip_cidr_range = "10.20.0.0/16"
      },
      {
        range_name    = var.ip_range_services_name
        ip_cidr_range = "10.30.0.0/16"
      },
    ]
  }
}

data "google_client_config" "default" {}

module "gke" {
  source            = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  version           = "~> 35.0"
  project_id        = var.project_id
  name              = var.prefix
  regional          = true
  region            = var.region
  network           = module.gcp_network.network_name
  subnetwork        = module.gcp_network.subnets_names[0]
  ip_range_pods     = var.ip_range_pods_name
  ip_range_services = var.ip_range_services_name

  service_account = var.cluster_service_account

  node_pools = [
    {
      name         = "${var.prefix}-node-pool"
      machine_type = var.instance_type
      min_count    = var.min_size
      max_count    = var.max_size
      node_count   = var.desired_size
      auto_upgrade = true
      auto_repair  = true
    },
  ]

  node_pools_labels = {
    all = var.labels
  }
}

resource "google_compute_global_address" "load_balancer" {
  name    = "${var.prefix}-load-balancer"
  project = var.project_id
  labels  = var.labels
}


module "memorystore" {
  count = var.create_redis ? 1 : 0

  source  = "terraform-google-modules/memorystore/google"
  version = "~> 12.0"

  name       = "${var.prefix}-redis"
  project_id = var.project_id
  region     = var.region

  connect_mode = "PRIVATE_SERVICE_ACCESS"

  auth_enabled = var.redis_auth_enabled
  enable_apis  = true

  memory_size_gb     = var.redis_size
  redis_version      = var.redis_version
  authorized_network = module.gcp_network.network_id

  transit_encryption_mode = var.redis_transit_encryption_mode

  labels = var.labels

  depends_on = [google_service_networking_connection.default]
}


data "google_compute_zones" "available" {
  region  = var.region
  project = var.project_id
  status  = "UP"
}

module "postgres" {
  count   = var.create_postgres ? 1 : 0
  source  = "GoogleCloudPlatform/sql-db/google//modules/postgresql"
  version = "~> 23.0"

  name                 = "${var.prefix}-postgresql"
  zone                 = data.google_compute_zones.available.names[0]
  random_instance_name = true
  project_id           = var.project_id
  database_version     = var.database_version
  region               = var.region

  create_timeout = "30m"

  tier                            = var.postgres_instance_tier
  availability_type               = var.database_availability_type
  maintenance_window_day          = var.database_maintenance_window_day
  maintenance_window_hour         = var.database_maintenance_window_hour
  maintenance_window_update_track = "stable"

  disk_size             = var.database_disk_size
  disk_autoresize       = var.database_disk_autoresize
  disk_autoresize_limit = var.database_disk_autoresize_limit

  deletion_protection = var.database_deletion_protection

  ip_configuration = {
    ipv4_enabled        = true
    require_ssl         = false
    private_network     = module.gcp_network.network_id
    allocated_ip_range  = null
    authorized_networks = []
  }

  backup_configuration = {
    enabled                        = true
    location                       = var.region
    start_time                     = "20:55"
    point_in_time_recovery_enabled = false
    retained_backups               = var.database_backup_retention
    retention_unit                 = "COUNT"
    transaction_log_retention_days = null
  }

  db_name     = var.database_name
  user_name   = var.database_username
  user_labels = var.labels

  depends_on = [google_service_networking_connection.default]
}


resource "google_compute_global_address" "private_ip_address" {
  name          = "${var.prefix}-private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = module.gcp_network.network_id
  labels        = var.labels
}

resource "google_service_networking_connection" "default" {
  network                 = module.gcp_network.network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_compute_network_peering_routes_config" "peering_routes" {
  peering              = google_service_networking_connection.default.peering
  network              = module.gcp_network.network_name
  import_custom_routes = true
  export_custom_routes = true
}

locals {
  bucket_name = var.bucket_name != "" ? var.bucket_name : "${var.prefix}-operations"
}

resource "google_storage_bucket" "polytomic" {
  name          = local.bucket_name
  location      = var.region
  project       = var.project_id
  force_destroy = true
  labels        = var.labels
}

resource "google_storage_bucket_iam_member" "polytomic" {
  count  = var.workload_identity_sa != "" ? 1 : 0
  bucket = google_storage_bucket.polytomic.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${var.workload_identity_sa}"
}

resource "google_storage_bucket_iam_member" "polytomic_logger" {
  count  = var.logger_workload_identity_sa != "" && var.logger_workload_identity_sa != var.workload_identity_sa ? 1 : 0
  bucket = google_storage_bucket.polytomic.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${var.logger_workload_identity_sa}"
}
