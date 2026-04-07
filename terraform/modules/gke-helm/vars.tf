variable "image_registry" {
  description = "Container image registry for all Polytomic images (e.g., us.gcr.io/polytomic-container-distro or us-docker.pkg.dev/project/repo). Equivalent to imageRegistry in the Helm chart."
  type        = string
}

variable "polytomic_image" {
  description = "Image name for the Polytomic container (without registry prefix). Combined with image_registry to form the full image reference."
  type        = string
  default     = "polytomic-onprem"
}

variable "polytomic_image_tag" {
  description = "The tag to use for the polytomic container"
  type        = string
}

variable "polytomic_deployment" {
  description = "The name of the polytomic deployment"
  type        = string
}

variable "polytomic_deployment_key" {
  description = "The key for the polytomic deployment"
  type        = string
  sensitive   = true
}

variable "polytomic_api_key" {
  description = "The api key for the polytomic deployment"
  type        = string
  default     = ""
}

variable "polytomic_url" {
  description = "The url for the polytomic deployment (hostname only, e.g., polytomic.example.com)"
  type        = string
}

variable "polytomic_cert_name" {
  description = "The name of the GCP managed SSL certificate for ingress"
  type        = string
}

variable "polytomic_ip_name" {
  description = "The name of the GCP global static IP for ingress"
  type        = string
}

variable "polytomic_root_user" {
  description = "The root user for the polytomic deployment"
  type        = string
  default     = "root"
}

variable "polytomic_google_client_id" {
  description = "Google OAuth client ID"
  type        = string
  default     = ""
}

variable "polytomic_google_client_secret" {
  description = "Google OAuth client secret"
  type        = string
  default     = ""
  sensitive   = true
}

variable "redis_password" {
  description = "The password for the Redis instance"
  type        = string
  sensitive   = true
}

variable "redis_host" {
  description = "The host for the Redis instance"
  type        = string
}

variable "redis_port" {
  description = "The port for the Redis instance"
  type        = number
  default     = 6379
}

variable "postgres_password" {
  description = "The password for the PostgreSQL instance"
  type        = string
  sensitive   = true
}

variable "postgres_host" {
  description = "The host for the PostgreSQL instance (private IP)"
  type        = string
}

variable "database_name" {
  description = "Name of the PostgreSQL database to connect to"
  type        = string
  default     = "polytomic"
}

variable "database_username" {
  description = "Username for the PostgreSQL database connection"
  type        = string
  default     = "polytomic"
}

variable "polytomic_bucket" {
  description = "The GCS bucket name for operational data"
  type        = string
}

variable "polytomic_service_account" {
  description = "GCP service account email for Workload Identity annotation on the Polytomic pods"
  type        = string
}

# Helm chart source

variable "chart_repository" {
  description = "The Helm chart repository URL. Leave empty to use local chart."
  type        = string
  default     = "https://charts.polytomic.com"
}

variable "chart_version" {
  description = "The version of the Polytomic Helm chart to install. Only used when chart_repository is set."
  type        = string
  default     = ""
}

variable "chart_path" {
  description = "Path to local Helm chart. Only used when chart_repository is empty. Defaults to relative path to chart in this repository."
  type        = string
  default     = ""
}

# Vector DaemonSet (log collection)

variable "polytomic_use_logger" {
  description = "Deploy Vector DaemonSet for stdout/stderr log collection. Disable to reduce costs in dev environments or if using alternative log collection."
  type        = bool
  default     = true
}

variable "polytomic_logger_image" {
  description = "Image name for the Vector DaemonSet."
  type        = string
  default     = "polytomic-vector"
}

variable "polytomic_logger_image_tag" {
  description = "Tag for the Vector DaemonSet image. Defaults to polytomic_image_tag when not set."
  type        = string
  default     = null
}

variable "polytomic_managed_logs" {
  description = "Enable Datadog log forwarding for both embedded Vector and DaemonSet."
  type        = bool
  default     = false
}

variable "polytomic_logger_service_account" {
  description = "Optional GCP service account email for Vector DaemonSet Workload Identity. Defaults to polytomic_service_account when unset."
  type        = string
  default     = null
}

# Datadog Agent DaemonSet (APM)

variable "polytomic_use_dd_agent" {
  description = "Deploy Datadog Agent DaemonSet for APM tracing."
  type        = bool
  default     = false
}

variable "polytomic_dd_agent_image" {
  description = "Image name for the Datadog Agent DaemonSet."
  type        = string
  default     = "polytomic-dd-agent"
}

variable "polytomic_dd_agent_image_tag" {
  description = "Tag for the Datadog Agent DaemonSet image. Defaults to polytomic_image_tag when not set."
  type        = string
  default     = null
}

# Helm release behavior

variable "force_update" {
  description = "Force Helm to update the release even if no changes are detected."
  type        = bool
  default     = false
}

variable "wait" {
  description = "Wait for all Kubernetes resources to be ready before marking the release as successful."
  type        = bool
  default     = false
}

variable "timeout" {
  description = "Timeout in seconds for waiting for resources to be ready. Only used when wait is true."
  type        = number
  default     = 600
}

variable "extra_helm_values" {
  description = "Additional Helm values in raw YAML format. Merged after the module's default values, so these take precedence."
  type        = string
  default     = ""
}
