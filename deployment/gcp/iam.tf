# IAM roles and permissions for the app to talk to external GCP services
resource "google_project_iam_custom_role" "ticket_booth" {
  role_id     = "fnfTicketBoothAppRole"
  title       = "Fnf Ticket Booth App Role"
  description = "Role that provides all the permissions needed by the app"
  permissions = [
    "cloudsql.databases.get",
    "cloudsql.databases.create",
    "cloudsql.databases.delete",
    "cloudsql.databases.get",
    "cloudsql.databases.update",
    "cloudsql.instances.connect",
    "cloudsql.instances.executeSql",
    "iam.serviceAccounts.get",
    "iam.serviceAccounts.getAccessToken",
    "iam.serviceAccounts.getOpenIdToken",
    "iam.serviceAccounts.list",
  ]
}

resource "google_service_account" "ticket_booth_gke" {
  account_id   = var.project_id
  description  = "Ticket Booth GKE Service Account"
  display_name = "ticket-booth-gke"

  create_ignore_already_exists = true
}

resource "google_service_account_iam_binding" "ticket_booth_app" {
  service_account_id = google_service_account.ticket_booth_gke.name
  role               = google_project_iam_custom_role.ticket_booth.name

  members = [
    "principal://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/${var.app_namespace}/sa/${var.app_service_account}",
  ]
}
