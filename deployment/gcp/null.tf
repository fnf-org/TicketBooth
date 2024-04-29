# This is needed because service account creation is eventually consistent

resource "null_resource" "wait_for_service_account" {
  provisioner "local-exec" {
    command = "sleep 15"
}
  triggers = {
    service_accounts = join(",", [
google_service_account.ticket_booth_gke.email,
])
}
}
