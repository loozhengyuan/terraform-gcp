output "name" {
  description = "The fully-qualified name of the service account."
  value       = google_service_account.service_account.name
}
