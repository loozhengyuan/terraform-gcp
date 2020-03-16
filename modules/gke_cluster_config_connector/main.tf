terraform {
  required_providers {
    google      = "~> 3.12"
    google-beta = "~> 3.12"
    kubernetes  = "~> 1.10"
  }
}

# Create Kubernetes namespace
resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "cnrm-system"
    labels = {
      managed_by = "terraform"
    }
    # Override annotations are meant to be set a separate namespace
    # https://cloud.google.com/config-connector/docs/how-to/setting-default-namespace
    # annotations = {
    #   "cnrm.cloud.google.com/project-id" = var.project
    #   # "cnrm.cloud.google.com/folder-id"
    #   # "cnrm.cloud.google.com/organization-id"
    # }
  }
}

# Create Google Service Account
resource "google_service_account" "service_account" {
  provider = google
  project  = var.project

  account_id   = "cnrm-system"
  display_name = "cnrm-system"
  description  = "Service account for Config Connector."
}

# Add IAM roles to Google Service Account
# Grant `roles/editor` for project-level management
# and `roles/owner` for organisation-level management.
resource "google_project_iam_member" "iam_roles" {
  provider = google
  project  = var.project

  role   = "roles/editor"
  member = "serviceAccount:${google_service_account.service_account.email}"
}

# Generate Google Service Account Key
resource "google_service_account_key" "key" {
  provider = google
  # Service account is not a project-level resource
  # project  = var.project

  service_account_id = google_service_account.service_account.name
}

# Mount Google Service Account Key as Kubernetes Secret in Namespace
resource "kubernetes_secret" "service_account" {
  metadata {
    name      = "cnrm-system"
    namespace = "cnrm-system"
  }

  data = {
    # Filename must be key.json
    "key.json" = base64decode(google_service_account_key.key.private_key)
  }
}

# MANUALLY INSTALL CUSTOM RESOURCE DEFINITIONS
# gsutil cp gs://cnrm/latest/release-bundle.tar.gz release-bundle.tar.gz
# tar zxvf release-bundle.tar.gz
# kubectl apply -f install-bundle-gcp-identity/

# CHECK IF INSTALLATION IS SUCCESSFUL
# kubectl wait -n cnrm-system \
#   --for=condition=Initialized pod \
#   cnrm-controller-manager-0

# MANUALLY UNINSTALL CUSTOM RESOURCE DEFINITIONS
# kubectl delete -f install-bundle-gcp-identity/crds.yaml
# kubectl delete -f install-bundle-gcp-identity/0-cnrm-system.yaml
# kubectl delete validatingwebhookconfiguration abandon-on-uninstall.cnrm-system.cnrm.cloud.google.com --ignore-not-found
# kubectl delete validatingwebhookconfiguration validating-webhook.cnrm.cloud.google.com --ignore-not-found
# kubectl delete mutatingwebhookconfiguration mutating-webhook.cnrm.cloud.google.com --ignore-not-found
