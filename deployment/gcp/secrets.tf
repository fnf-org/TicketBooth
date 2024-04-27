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
    "TICKET_DB_HOST"     = tostring(google_sql_database_instance.ticket_booth.connection_name)
    "TICKET_DB_NAME"     = tostring(google_sql_database.ticket_booth.name)
    "TICKET_DB_USER"     = "fnf-breakglass"
    "TICKET_DB_PASSWORD" = tostring(random_password.ticket_booth_db.result)
  }))
}

resource "google_secret_manager_secret" "ticket_booth_app" {
  secret_id = "ticket-booth-app"

  replication {
    auto {}
  }
}
