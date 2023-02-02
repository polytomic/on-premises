output "cluster_name" {
  description = "Cluster name"
  value       = module.gke.name
}

output "sa" {
  description = "Service account"
  value       = module.gke.service_account
}

output "lb_ip" {
  description = "Load balancer IP"
  value       = resource.google_compute_global_address.load_balancer.address
}

output "lb_name" {
  description = "Load balancer IP Name"
  value       = resource.google_compute_global_address.load_balancer.name
}

output "redis_auth_string" {
  value = module.memorystore[0].auth_string
}

output "redis_host" {
  value = module.memorystore[0].host
}

output "redis_port" {
  value = module.memorystore[0].port
}

output "postgres_password" {
  value = module.postgres[0].generated_user_password
}

output "postgres_host" {
  value = module.postgres[0].instance_connection_name
}

output "postgres_ip" {
  value = module.postgres[0].private_ip_address
}
