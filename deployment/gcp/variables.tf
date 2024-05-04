variable "app_namespace" {
  default     = "fnf-apps"
  description = "GKE namespace where the app is deployed"
  type        = string
}

variable "app_service_account" {
  default     = "ticket-booth-sa"
  description = "The GKE ServiceAccount used by the app"
  type        = string
}

variable "environment" {
  default     = "production"
  description = "App deployment environment"
  type        = string
}

variable "location" {
  default = "us-central1"
  type    = string
}

variable "postgres_major_version" {
  default     = "POSTGRES_15"
  description = "CloudSQL Postgres version identifier"
  type        = string
}

variable "project_id" {
  default = "fnf-apps-341500"
  type    = string
}

variable "project_number" {
  default = "309199342732"
  type    = string
}

variable "secret_manager_service_account" {
  default     = "external-secrets-gke@fnf-apps-341500.iam.gserviceaccount.com"
  description = "The GCP SA used by ExternalSecrets to fetch SecretManager Secret"
}

variable "tf_service_account" {
  default     = "tf-manager@fnf-apps-341500.iam.gserviceaccount.com"
  description = "GCP SA email to assume to apply changes. Not Currently Used"
  type        = string
}

