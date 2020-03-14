terraform {
  required_providers {
    google = "~> 3.12"
  }
}

resource "google_project_iam_member" "user_role" {
  provider = google
  project  = var.project

  for_each = var.roles

  role   = each.value
  member = "user:${var.email}"
}
