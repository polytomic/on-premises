output "cluster_name" {
  description = "Cluster name"
  value       = module.eks.cluster_name
}

output "cluster_arn" {
  description = "Cluster ARN"
  value       = module.eks.cluster_arn
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.eks.vpc_id
}

output "public_subnets" {
  description = "Subnet IDs"
  value       = module.eks.public_subnets
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN"
  value       = module.eks.oidc_provider_arn
}

output "redis_auth_string" {
  value     = module.eks.redis_auth_string
  sensitive = true
}

output "redis_host" {
  value = module.eks.redis_host
}

output "redis_port" {
  value = module.eks.redis_port
}

output "postgres_password" {
  value     = module.eks.postgres_password
  sensitive = true
}

output "postgres_host" {
  value = module.eks.postgres_host
}

output "filesystem_id" {
  value = module.eks.filesystem_id
}

output "bucket" {
  value = module.eks.bucket
}