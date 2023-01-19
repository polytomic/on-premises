output "cluster_name" {
  description = "Cluster name"
  value       = module.gke.name
}

output "kubeconfig_file" {
  description = "Kubeconfig file"
  value       = local_file.kubeconfig.filename
}

output "cluster_ca_certificate" {
  description = "Cluster CA certificate"
  value       = module.gke_auth.cluster_ca_certificate
}

output "cluster_endpoint" {
  description = "Cluster endpoint"
  value       = module.gke_auth.host
}

output "cluster_token" {
  description = "Cluster token"
  value       = module.gke_auth.token
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
  value = module.memorystore.*.auth_string
}

output "redis_host" {
  value = module.memorystore.*.host
}

output "redis_port" {
  value = module.memorystore.*.port
}

output "postgres_password" {
  value = module.postgres.*.generated_user_password
}

output "postgres_host" {
  value = module.postgres.*.instance_connection_name
}

output "postgres_ip" {
  value = module.postgres.*.private_ip_address
}
