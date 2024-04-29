# This creates the secret store locations, entries will need to be manually updated

resource "google_secret_manager_secret" "ticket_booth_db" {
  secret_id = "ticket-booth-db"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "ticket_booth_db" {
  secret = google_secret_manager_secret.ticket_booth_db.id

  secret_data = base64encode(jsonencode({
    "TICKET_DB_HOST"                = tostring(google_sql_database_instance.ticket_booth.connection_name)
    "TICKET_DB_NAME"                = tostring(google_sql_database.ticket_booth.name)
    "TICKET_DB_BREAKGLASS_USER"     = "fnf-breakglass"
    "TICKET_DB_BREAKGLASS_PASSWORD" = tostring(random_password.ticket_booth_db.result)
  }))

  lifecycle {
    # Don't want this resource overwriting the latest value if that changes
    ignore_changes = [
      google_secret_manager_secret_version.ticket_booth_db.version,
    ]
  }
}

resource "google_secret_manager_secret" "ticket_booth_app" {
  secret_id = "ticket-booth-app"

  replication {
    auto {}
  }
}

# Make sure the secrets have policies allowing ExternalSecrets to fetch them.
resource "google_secret_manager_secret_iam_policy_binding" "ticket_booth_db" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.ticket_booth_db.id
  role      = "roles/secretmanager.secretAccessor"
  memebers = [
    var.secret_manager_service_account,
  ]
}

resource "google_secret_manager_secret_iam_policy_binding" "ticket_booth_app" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.ticket_booth_app.id
  role      = "roles/secretmanager.secretAccessor"
  memebers = [
    var.secret_manager_service_account,
  ]
}

# Use these values in the Helm values file
output "sql_db_secret_manager_id" {
  value = google_secret_manager_secret.ticket_booth_db.id
}

output "app_secret_manager_id" {
  value = google_secret_manager_secret.ticket_booth_app.id
}
