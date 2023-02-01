module "gcp_network" {
  source       = "terraform-google-modules/network/google"
  version      = "6.0.0"
  project_id   = var.project_id
  network_name = "polytomic"

  subnets = [
    {
      subnet_name   = "polytomic"
      subnet_ip     = "10.10.0.0/16"
      subnet_region = var.region
    },
  ]

  secondary_ranges = {
    "polytomic" = [
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
  version           = "24.1.0"
  project_id        = var.project_id
  name              = "polytomic"
  regional          = true
  region            = var.region
  network           = module.gcp_network.network_name
  subnetwork        = module.gcp_network.subnets_names[0]
  ip_range_pods     = var.ip_range_pods_name
  ip_range_services = var.ip_range_services_name

  service_account = var.cluster_service_account
}

resource "google_compute_global_address" "load_balancer" {
  name = "polytomic-load-balancer"
}


module "memorystore" {
  count = var.create_redis ? 1 : 0

  source = "terraform-google-modules/memorystore/google"

  name         = "polytomic-redis"
  project      = var.project_id
  connect_mode = "PRIVATE_SERVICE_ACCESS"

  auth_enabled = true
  enable_apis  = true

  memory_size_gb     = var.redis_size
  authorized_network = module.gcp_network.network_id

  transit_encryption_mode = "DISABLED"
}


data "google_compute_zones" "available" {
  region  = var.region
  project = var.project_id
  status  = "UP"
}

module "postgres" {
  count  = var.create_postgres ? 1 : 0
  source = "GoogleCloudPlatform/sql-db/google//modules/postgresql"

  name                 = "polytomic-postgresql"
  zone                 = data.google_compute_zones.available.names[0]
  random_instance_name = true
  project_id           = var.project_id
  database_version     = "POSTGRES_14"
  region               = var.region

  create_timeout = "30m"

  // Master configurations
  tier                            = var.postgres_instance_tier
  availability_type               = "REGIONAL"
  maintenance_window_day          = 7
  maintenance_window_hour         = 12
  maintenance_window_update_track = "stable"

  deletion_protection = false

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
    retained_backups               = 7
    retention_unit                 = "COUNT"
    transaction_log_retention_days = null
  }

  db_name   = "polytomic"
  user_name = "polytomic"
}


resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = module.gcp_network.network_id
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
