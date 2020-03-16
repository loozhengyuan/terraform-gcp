terraform {
  required_providers {
    google      = "~> 3.12"
    google-beta = "~> 3.12"
    kubernetes  = "~> 1.10"
  }
}

locals {
  ksa_namespace = "workload-identity"
  ksa_name      = "workload-identity"
  gsa_name      = "workload-identity"
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
    name = local.ksa_namespace
    labels = {
      managed_by = "terraform"
    }
  }
}

# Create Google Service Account
resource "google_service_account" "service_account" {
  provider = google
  project  = var.project

  account_id   = local.gsa_name
  display_name = local.gsa_name
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
    name      = local.ksa_name
    namespace = local.ksa_namespace
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
  member = "serviceAccount:${var.project}.svc.id.goog[${local.ksa_namespace}/${local.ksa_name}]"
}
