variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}


variable "prefix" {
  description = "Prefix for all resources"
  default     = "polytomic"
}

variable "vpc_id" {
  description = "VPC ID"
  default     = ""
}


variable "cluster_name" {
  description = "EKS cluster name"
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN"
}

variable "enable_cluster_autoscaler" {
  description = "Deploy the Kubernetes Cluster Autoscaler for automatic node scaling"
  type        = bool
  default     = false
}
