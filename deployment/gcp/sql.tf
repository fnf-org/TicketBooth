locals {
  db_admins = [
    "evilmonkey@gmail.com",
    "matt@fnf.org",
  ]
}

resource "google_sql_database_instance" "ticket_booth" {
  name             = "fnf-apps-db-instance"
  database_version = "POSTGRES_15"
  region           = var.location

  settings {
    tier = "db-g1-small"

    # Only allow access from the GKE cluster
    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = data.google_compute_network.default_vpc.id
      enable_private_path_for_google_cloud_services = true
      #  authorized_networks {
      #    name = ""
      #    value = ""
      #  }
    }

    availability_type = "REGIONAL"

    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }

    # activation_policy           = "ON_DEMAND"
    deletion_protection_enabled = true

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

output "ticket_db_instance_name" {
  value = google_sql_database_instance.ticket_booth.name
}

resource "google_sql_database" "ticket_booth" {
  name     = "tickets"
  instance = google_sql_database_instance.ticket_booth.name
}

resource "google_sql_user" "fnf_apps_admin_users" {
  for_each = toset(local.db_admins)
  name     = each.value
  instance = google_sql_database_instance.ticket_booth.name
  type     = "CLOUD_IAM_USER"
}

resource "google_sql_user" "fnf_apps_gke_sa" {
  name     = trimsuffix(google_service_account.ticket_booth_gke.email, ".gserviceaccount.com")
  instance = google_sql_database_instance.ticket_booth.name
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
}

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
