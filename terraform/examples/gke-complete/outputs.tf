output "cluster_name" {
  description = "Cluster name"
  value       = module.gke.cluster_name
}

output "kubeconfig_file" {
  description = "Kubeconfig file"
  value       = module.gke.kubeconfig_file
}

output "default_account" {
  description = "Compute Engine default service account"
  value       = module.gke.sa
}

output "load_balancer_ip" {
  description = "Load balancer IP"
  value       = module.gke.lb_ip
}

output "cluster_sa" {
  description = "Cluster service account"
  value       = module.gke_cluster_service_account.email
}

output "redis_auth_string" {
  value     = module.gke.redis_auth_string
  sensitive = true
}

