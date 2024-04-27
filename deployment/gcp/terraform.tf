terraform {
  backend "gcs" {
    bucket = "fnf-apps-terraform-state"
    prefix = "ticket-booth"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.25.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.location

  impersonate_service_account = var.tf_service_account != "" ? var.tf_service_account : ""
}
