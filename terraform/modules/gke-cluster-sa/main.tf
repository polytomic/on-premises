resource "google_service_account" "cluster_service_account" {
  project      = var.project_id
  account_id   = "pt-cluster-sa"
  display_name = "Terraform-managed service account for cluster"
}

resource "google_project_iam_member" "cluster_service_account-log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cluster_service_account.email}"
}

resource "google_project_iam_member" "cluster_service_account-metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.cluster_service_account.email}"
}

resource "google_project_iam_member" "cluster_service_account-monitoring_viewer" {
  project = var.project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.cluster_service_account.email}"
}

resource "google_project_iam_member" "cluster_service_account-resourceMetadata-writer" {
  project = var.project_id
  role    = "roles/stackdriver.resourceMetadata.writer"
  member  = "serviceAccount:${google_service_account.cluster_service_account.email}"
}

resource "google_service_account" "workload-identity-user-sa" {
  project      = var.project_id
  account_id   = "workload-identity-user-sa"
  display_name = "Service Account For Workload Identity"
}
resource "google_project_iam_member" "storage-role" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.workload-identity-user-sa.email}"
}
resource "google_project_iam_member" "workload-identity-role" {
  project = var.project_id
  role    = "roles/iam.workloadIdentityUser"
  # ${var.project_id}].svc.id.goog  == kubernetes cluster idenity namespace
  # [polytomic/polytomic] == [kubernetes namespace/service account name]
  member = "serviceAccount:${var.project_id}.svc.id.goog[polytomic/polytomic]"
}