variable "project_id" {
  description = "The project ID to host the cluster in"
}

variable "region" {
  description = "The region to host the cluster in"
  default     = "us-east1"
}

variable "cluster_service_account" {
  description = "The service account to use for the cluster"
}

variable "ip_range_pods_name" {
  description = "The secondary ip range to use for pods"
  default     = "ip-range-pods"
}
variable "ip_range_services_name" {
  description = "The secondary ip range to use for services"
  default     = "ip-range-services"
}


variable "create_redis" {
  description = "Whether to create a redis instance"
  default     = true
}


variable "redis_size" {
  description = "The size of the redis instance in GB"
  default     = "1"
}


variable "create_postgres" {
  description = "Whether to create a postgres instance"
  default     = true
}

variable "postgres_instance_tier" {
  description = "The tier of the postgres instance"
  default     = "db-f1-micro"
}

variable "bucket_name" {
  description = "The GCS bucket name to use. Must be globally unique. Recommended format: '<company>-polytomic-operations' or similar."
  default     = "polytomic-operations"
}


variable "workload_identity_sa" {
  description = "The name of the workload identity user service account"
  default     = ""
}
