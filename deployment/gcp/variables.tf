variable "tf_service_account" {
  default = "sa-cluster@fnf-apps-341500.iam.gserviceaccount.com"
  type    = string
}

variable "project_id" {
  default = "fnf-apps-341500"
  type    = string
}

variable "location" {
  default = "us-central1"
  type    = string
}
