variable "project_id" {
  type        = string
  description = "The project ID to deploy the resources to"
}

variable "logger_workload_identity_sa" {
  type        = string
  description = "Optional GCP service account email for the polytomic-vector Kubernetes service account. Defaults to the module-managed workload identity service account when unset."
  default     = null
}
