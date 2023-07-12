output "email" {
  description = "Service account email"
  value       = google_service_account.cluster_service_account.email
}

output "workload_identity_user_sa_email" {
  description = "Workload identity user service account email"
  value       = google_service_account.workload-identity-user-sa.email
}