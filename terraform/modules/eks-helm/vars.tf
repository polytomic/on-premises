variable "polytomic_image" {
  description = "The image to use for the polytomic container"
}

variable "polytomic_image_tag" {
  description = "The tag to use for the polytomic container"
}

variable "polytomic_deployment" {
  description = "The name of the polytomic deployment"
}

variable "polytomic_deployment_key" {
  description = "The key for the polytomic deployment"
}

variable "polytomic_url" {
  description = "The url for the polytomic deployment"
}

variable "polytomic_root_user" {
  description = "The root user for the polytomic deployment"
  default     = "root"
}

variable "polytomic_google_client_id" {
  description = "The google client id for the polytomic deployment"
}

variable "polytomic_google_client_secret" {
  description = "The google client secret for the polytomic deployment"
}

variable "redis_password" {
  description = "The password for the redis deployment"
  default     = ""
}

variable "redis_host" {
  description = "The host for the redis deployment"
}

variable "redis_port" {
  description = "The port for the redis deployment"
  default     = 6379
}

variable "postgres_password" {
  description = "The password for the postgres deployment"
}

variable "postgres_host" {
  description = "The host for the postgres deployment"
}

variable "certificate_arn" {
  description = "The arn of the certificate to use for the polytomic deployment. If not provided, the ALB will listen on HTTP (port 80) only."
  default     = ""
}

variable "subnets" {
  description = "The subnets to use for the polytomic deployment"
  type        = string
}


variable "polytomic_bucket" {
  description = "The operational bucket for the polytomic deployment"
}

variable "polytomic_bucket_region" {
  description = "The operational bucket regoin for the polytomic deployment"
}

variable "efs_id" {
  description = "ID of the EFS volume to use for the polytomic deployment"
}

variable "polytomic_service_account_role_arn" {
  description = "ARN of the role to use for the polytomic deployment service account"
}

variable "polytomic_api_key" {
  default     = ""
  description = "The api key for the polytomic deployment"
}

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