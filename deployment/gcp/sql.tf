resource "google_sql_database_instance" "ticket_booth" {
  name             = "ticket-db-instance-${var.environment}"
  database_version = var.postgres_major_version
  region           = var.location

  settings {
    tier = "db-g1-small"

    # Only allow access from the GKE cluster
    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = data.google_compute_network.default_vpc.id
      enable_private_path_for_google_cloud_services = true
    }

    availability_type = "REGIONAL"

    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }

    # deletion_protection_enabled = true

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true

      backup_retention_settings {
        retained_backups = 10
      }
    }
  }

  depends_on = [google_service_networking_connection.private_vpc_connection]
}

resource "google_sql_database" "ticket_booth" {
  name     = "ticketing_app_${var.environment}"
  instance = google_sql_database_instance.ticket_booth.name
}

resource "google_sql_user" "fnf_apps_gke_sa" {
  name     = trimsuffix(google_service_account.ticket_booth_gke.email, ".gserviceaccount.com")
  instance = google_sql_database_instance.ticket_booth.name
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
}

# Last ditch recovery user. Only needed if IAM authentication is broken
resource "google_sql_user" "breakglass" {
  name     = "fnf-breakglass"
  instance = google_sql_database_instance.ticket_booth.name
  password = random_password.ticket_booth_db.result
}

resource "random_password" "ticket_booth_db" {
  length           = 20
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

output "ticket_db_instance_name" {
  value = google_sql_database_instance.ticket_booth.name
}
