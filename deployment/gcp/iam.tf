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
  ]
}

locals {
  app_roles = toset([
    "roles/cloudsql.editor",
    "roles/cloudkms.cryptoKeyEncrypterDecrypter",
  ])
}

resource "google_service_account" "ticket_booth_gke" {
  account_id   = var.project_id
  description  = "Ticket Booth GKE Service Account"
  display_name = "ticket-booth-gke"

  create_ignore_already_exists = true
}

resource "google_service_account_iam_binding" "ticket_booth_app" {
  service_account_id = google_service_account.ticket_booth_gke.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "principal://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/${var.app_namespace}/sa/${var.app_service_account}",
  ]

  depends_on = [
    null_resource.wait_for_service_account,
  ]
}

resource "google_project_iam_binding" "ticket_booth_app_custom" {
  project = var.project_id
  role    = google_project_iam_custom_role.ticket_booth.name

  members = [
    google_service_account.ticket_booth_gke.member,
  ]

  depends_on = [
    null_resource.wait_for_service_account,
  ]
}

resource "google_project_iam_binding" "ticket_booth_app_builtins" {
  for_each = local.app_roles

  project = var.project_id
  role    = each.value

  members = [
    google_service_account.ticket_booth_gke.member,
  ]

  depends_on = [
    null_resource.wait_for_service_account,
  ]
}
