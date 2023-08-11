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
  value       = module.vpc[0].vpc_id
}

output "public_subnets" {
  description = "Subnet IDs"
  value       = module.vpc[0].public_subnets
}


output "oidc_provider_arn" {
  description = "OIDC provider ARN"
  value       = module.eks.oidc_provider_arn
}

output "redis_auth_string" {
  value = random_password.redis[0].result
}

output "redis_host" {
  value = module.redis[0].elasticache_replication_group_primary_endpoint_address
}

output "redis_port" {
  value = var.redis_port
}

output "postgres_password" {
  value = module.database[0].db_instance_password
}

output "postgres_host" {
  value = module.database[0].db_instance_address
}

output "filesystem_id" {
  value = module.efs[0].id
}

output "bucket" {
  value = module.s3_bucket.s3_bucket_id
}