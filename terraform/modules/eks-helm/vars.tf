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
  description = "The arn of the certificate to use for the polytomic deployment"
}

variable "subnets" {
  description = "The subnets to use for the polytomic deployment"
  type        = string
}
