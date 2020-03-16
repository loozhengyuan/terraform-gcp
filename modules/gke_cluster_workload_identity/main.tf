terraform {
  required_providers {
    google      = "~> 3.12"
    google-beta = "~> 3.12"
    kubernetes  = "~> 1.10"
  }
}

# Enable IAM Service Account Credentials API
resource "google_project_service" "container" {
  project = var.project
  service = "iamcredentials.googleapis.com"

  # Ensures that this resource block will only
  # be concerned with enabling this API if disabled
  disable_dependent_services = false
  disable_on_destroy         = false
}

# Create Kubernetes namespace
resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.namespace
    labels = {
      managed_by = "terraform"
    }
  }
}

# Create Google Service Account
resource "google_service_account" "service_account" {
  provider = google
  project  = var.project

  account_id   = var.gsa_name
  display_name = var.gsa_name
  description  = "Service account for Workload Identity."
}

# Add IAM roles to Google Service Account
resource "google_project_iam_member" "iam_roles" {
  provider = google
  project  = var.project

  role   = "roles/editor"
  member = "serviceAccount:${google_service_account.service_account.email}"
}

# Create Kubernetes Service Account in Namespace
# Add annotation for KSA-GSA binding
resource "kubernetes_service_account" "service_account" {
  metadata {
    name      = var.ksa_name
    namespace = var.namespace
    labels = {
      managed_by = "terraform"
    }
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.service_account.email
    }
  }
}

# Bind KSA to GSA via IAM
resource "google_service_account_iam_member" "gsa_ksa_iam_policy_binding" {
  service_account_id = google_service_account.service_account.name

  role   = "roles/iam.workloadIdentityUser"
  member = "serviceAccount:${var.project}.svc.id.goog[${var.namespace}/${var.ksa_name}]"
}
