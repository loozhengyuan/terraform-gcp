terraform {
  required_providers {
    google = "~> 3.12"
  }
}

resource "google_service_account" "service_account" {
  provider = google
  project  = var.project

  account_id   = var.name
  display_name = var.name
  description  = var.description
}

resource "google_project_iam_member" "service_account_role" {
  provider = google
  project  = var.project

  for_each = var.roles

  role   = each.value
  member = "serviceAccount:${google_service_account.service_account.email}"
}
