variable "app_namespace" {
  default     = "default"
  description = "GKE namespace where the app is deployed"
  type        = string
}

variable "app_service_account" {
  default     = "ticket-booth-sa"
  description = "The GKE ServiceAccount used by the app"
  type        = string
}

variable "location" {
  default = "us-central1"
  type    = string
}

variable "project_id" {
  default = "fnf-apps-341500"
  type    = string
}

variable "project_number" {
  default = "309199342732"
  type    = string
}

variable "tf_service_account" {
  default = "sa-cluster@fnf-apps-341500.iam.gserviceaccount.com"
  type    = string
}

