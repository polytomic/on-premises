variable "project_id" {
  description = "The GCP project ID to host the cluster in"
  type        = string
}

variable "region" {
  description = "The region to host the cluster in"
  type        = string
  default     = "us-east1"
}

variable "prefix" {
  description = "Prefix for all resource names"
  type        = string
  default     = "polytomic"
}

variable "labels" {
  description = "Labels to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "cluster_service_account" {
  description = "The service account to use for the cluster"
  type        = string
}

# Networking

variable "ip_range_pods_name" {
  description = "The secondary ip range to use for pods"
  type        = string
  default     = "ip-range-pods"
}

variable "ip_range_services_name" {
  description = "The secondary ip range to use for services"
  type        = string
  default     = "ip-range-services"
}

# GKE Cluster

variable "instance_type" {
  description = "Machine type for GKE nodes"
  type        = string
  default     = "e2-standard-4"
}

variable "min_size" {
  description = "Minimum number of nodes in the node pool"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of nodes in the node pool"
  type        = number
  default     = 4
}

variable "desired_size" {
  description = "Initial number of nodes in the node pool"
  type        = number
  default     = 3
}

# PostgreSQL (Cloud SQL)

variable "create_postgres" {
  description = "Whether to create a Cloud SQL PostgreSQL instance"
  type        = bool
  default     = true
}

variable "database_name" {
  description = "Name of the database to create"
  type        = string
  default     = "polytomic"
}

variable "database_username" {
  description = "Username for the database"
  type        = string
  default     = "polytomic"
}

variable "database_version" {
  description = "Cloud SQL database version"
  type        = string
  default     = "POSTGRES_17"
}

variable "postgres_instance_tier" {
  description = "The tier (machine type) of the Cloud SQL instance"
  type        = string
  default     = "db-custom-2-7680"
}

variable "database_edition" {
  description = "The edition of the Cloud SQL instance (ENTERPRISE or ENTERPRISE_PLUS)"
  type        = string
  default     = "ENTERPRISE"
}

variable "database_deletion_protection" {
  description = "Whether to enable deletion protection on the database"
  type        = bool
  default     = true
}

variable "database_backup_retention" {
  description = "Number of backups to retain"
  type        = number
  default     = 30
}

variable "database_availability_type" {
  description = "Availability type for Cloud SQL (REGIONAL for HA, ZONAL for single zone)"
  type        = string
  default     = "REGIONAL"
}

variable "database_maintenance_window_day" {
  description = "Day of the week for maintenance window (1=Mon, 7=Sun)"
  type        = number
  default     = 7
}

variable "database_maintenance_window_hour" {
  description = "Hour of the day for maintenance window (0-23)"
  type        = number
  default     = 0
}

variable "database_disk_size" {
  description = "Disk size in GB for the Cloud SQL instance"
  type        = number
  default     = 20
}

variable "database_disk_autoresize" {
  description = "Whether to enable disk autoresize"
  type        = bool
  default     = true
}

variable "database_disk_autoresize_limit" {
  description = "Maximum disk size in GB when autoresize is enabled (0 = unlimited)"
  type        = number
  default     = 100
}

# Redis (Memorystore)

variable "create_redis" {
  description = "Whether to create a Memorystore Redis instance"
  type        = bool
  default     = true
}

variable "redis_size" {
  description = "The size of the Redis instance in GB"
  type        = number
  default     = 1
}

variable "redis_version" {
  description = "Redis version for Memorystore"
  type        = string
  default     = "REDIS_7_2"
}

variable "redis_auth_enabled" {
  description = "Whether to enable AUTH on the Redis instance"
  type        = bool
  default     = true
}

variable "redis_transit_encryption_mode" {
  description = "Transit encryption mode for Redis (DISABLED or SERVER_AUTHENTICATION)"
  type        = string
  default     = "DISABLED"
}

variable "redis_maintenance_window_day" {
  description = "Day of the week for Redis maintenance (MONDAY through SUNDAY)"
  type        = string
  default     = "MONDAY"
}

variable "redis_maintenance_window_hour" {
  description = "Hour for Redis maintenance window (0-23 UTC)"
  type        = number
  default     = 3
}

# Storage

variable "bucket_name" {
  description = "The GCS bucket name to use. Must be globally unique."
  type        = string
  default     = ""
}

variable "workload_identity_sa" {
  description = "The email of the workload identity user service account"
  type        = string
  default     = ""
}

variable "logger_workload_identity_sa" {
  description = "Optional email of a dedicated logger workload identity service account that should also receive bucket write access"
  type        = string
  default     = ""
}
