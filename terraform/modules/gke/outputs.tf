output "cluster_name" {
  description = "GKE cluster name"
  value       = module.gke.name
}

output "sa" {
  description = "Service account used by the cluster"
  value       = module.gke.service_account
}

output "lb_ip" {
  description = "Load balancer IP address"
  value       = google_compute_global_address.load_balancer.address
}

output "lb_name" {
  description = "Load balancer IP name"
  value       = google_compute_global_address.load_balancer.name
}

output "cert_name" {
  description = "Name of the managed SSL certificate for the main Polytomic host. Empty when create_managed_certificate is false or polytomic_url is unset."
  value       = length(google_compute_managed_ssl_certificate.polytomic) > 0 ? google_compute_managed_ssl_certificate.polytomic[0].name : ""
}

output "mcp_lb_ip" {
  description = "MCP load balancer IP address. Empty when polytomic_mcp_url is unset."
  value       = length(google_compute_global_address.mcp) > 0 ? google_compute_global_address.mcp[0].address : ""
}

output "mcp_lb_name" {
  description = "MCP load balancer IP name. Empty when polytomic_mcp_url is unset."
  value       = length(google_compute_global_address.mcp) > 0 ? google_compute_global_address.mcp[0].name : ""
}

output "mcp_cert_name" {
  description = "Name of the managed SSL certificate for the MCP host. Empty when create_managed_certificate is false or polytomic_mcp_url is unset."
  value       = length(google_compute_managed_ssl_certificate.mcp) > 0 ? google_compute_managed_ssl_certificate.mcp[0].name : ""
}

output "network_name" {
  description = "VPC network name"
  value       = module.gcp_network.network_name
}

output "network_id" {
  description = "VPC network ID"
  value       = module.gcp_network.network_id
}

output "redis_auth_string" {
  description = "Redis AUTH string"
  value       = var.create_redis ? module.memorystore[0].auth_string : ""
}

output "redis_host" {
  description = "Redis host"
  value       = var.create_redis ? module.memorystore[0].host : ""
}

output "redis_port" {
  description = "Redis port"
  value       = var.create_redis ? module.memorystore[0].port : ""
}

output "postgres_password" {
  description = "PostgreSQL generated user password"
  value       = var.create_postgres ? module.postgres[0].generated_user_password : ""
  sensitive   = true
}

output "postgres_host" {
  description = "PostgreSQL instance connection name"
  value       = var.create_postgres ? module.postgres[0].instance_connection_name : ""
}

output "postgres_ip" {
  description = "PostgreSQL private IP address"
  value       = var.create_postgres ? module.postgres[0].private_ip_address : ""
}

output "database_name" {
  description = "Configured PostgreSQL database name"
  value       = var.database_name
}

output "database_username" {
  description = "Configured PostgreSQL database username"
  value       = var.database_username
}

output "bucket" {
  description = "GCS bucket name"
  value       = google_storage_bucket.polytomic.name
}

output "workload_identity_user_sa" {
  description = "Workload Identity service account email — send to Polytomic for registry access"
  value       = var.workload_identity_sa
}
