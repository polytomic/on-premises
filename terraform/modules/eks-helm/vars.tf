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

variable "polytomic_logger_image" {
  description = "Docker image repository for Vector DaemonSet with ptconf for secret decryption"
  type        = string
  default     = "568237466542.dkr.ecr.us-west-2.amazonaws.com/polytomic-vector"
}

variable "polytomic_logger_image_tag" {
  description = "Tag for the Vector DaemonSet image. Defaults to polytomic_image_tag when not set."
  type        = string
  default     = null
}

variable "polytomic_use_logger" {
  description = "Deploy Vector DaemonSet for stdout/stderr log collection. Disable to reduce costs in dev environments or if using alternative log collection. Matches ECS module variable."
  type        = bool
  default     = true
}

variable "polytomic_managed_logs" {
  description = "Enable Datadog log forwarding for both embedded Vector and DaemonSet. Matches ECS module variable."
  type        = bool
  default     = false
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA (IAM Roles for Service Accounts). Required for Vector DaemonSet IAM role."
  type        = string
  default     = ""
}

variable "execution_log_bucket_arn" {
  description = "ARN of the S3 bucket for execution logs. Used for Vector DaemonSet IAM permissions."
  type        = string
  default     = ""
}