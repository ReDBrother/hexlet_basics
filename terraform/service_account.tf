resource "google_service_account" "cloudsql_proxy" {
  project    = var.project_name
  account_id = "cloudsql-proxy"
}

resource "google_project_iam_member" "cloudsql_proxy" {
  project = var.project_name
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.cloudsql_proxy.email}"
}

resource "google_service_account_key" "cloudsql_proxy" {
  service_account_id = google_service_account.cloudsql_proxy.name
}
