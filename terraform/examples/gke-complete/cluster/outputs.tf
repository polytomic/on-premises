output "cluster_name" {
  description = "GKE cluster name"
  value       = module.gke.cluster_name
}

output "default_account" {
  description = "Compute Engine default service account"
  value       = module.gke.sa
}

output "load_balancer_ip" {
  description = "Load balancer IP"
  value       = module.gke.lb_ip
}

output "load_balancer_name" {
  description = "Load balancer name"
  value       = module.gke.lb_name
}

output "cluster_sa" {
  description = "Cluster service account"
  value       = module.gke_cluster_service_account.email
}

output "workload_identity_user_sa" {
  description = "Workload identity user service account"
  value       = module.gke_cluster_service_account.workload_identity_user_sa_email
}

output "redis_auth_string" {
  description = "Redis AUTH string"
  value       = module.gke.redis_auth_string
  sensitive   = true
}

output "redis_host" {
  description = "Redis host"
  value       = module.gke.redis_host
}

output "redis_port" {
  description = "Redis port"
  value       = module.gke.redis_port
}

output "postgres_password" {
  description = "PostgreSQL password"
  value       = module.gke.postgres_password
  sensitive   = true
}

output "postgres_host" {
  description = "PostgreSQL connection name"
  value       = module.gke.postgres_host
}

output "postgres_ip" {
  description = "PostgreSQL private IP"
  value       = module.gke.postgres_ip
}

output "database_name" {
  description = "Configured PostgreSQL database name"
  value       = module.gke.database_name
}

output "database_username" {
  description = "Configured PostgreSQL database username"
  value       = module.gke.database_username
}

output "bucket" {
  description = "GCS bucket name"
  value       = module.gke.bucket
}
