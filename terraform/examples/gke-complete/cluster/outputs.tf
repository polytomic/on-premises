output "cluster_name" {
  description = "Cluster name"
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

output "redis_auth_string" {
  value     = module.gke.redis_auth_string
  sensitive = true
}

output "redis_host" {
  value = module.gke.redis_host
}

output "redis_port" {
  value = module.gke.redis_port
}

output "postgres_password" {
  value     = module.gke.postgres_password
  sensitive = true
}

output "postgres_host" {
  value = module.gke.postgres_host
}

output "postgres_ip" {
  value = module.gke.postgres_ip
}
