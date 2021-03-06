terraform {
  required_providers {
    google      = "~> 3.12"
    google-beta = "~> 3.12"
  }
}

# Enable Google Kubernetes API
resource "google_project_service" "container" {
  project = var.project
  service = "container.googleapis.com"

  # Ensures that this resource block will only
  # be concerned with enabling this API if disabled
  disable_dependent_services = false
  disable_on_destroy         = false
}

# Create custom Google Service Account for GKE cluster and nodes for better security
# https://cloud.google.com/kubernetes-engine/docs/how-to/protecting-cluster-metadata
# https://cloud.google.com/kubernetes-engine/docs/how-to/hardening-your-cluster#use_least_privilege_sa
module "google_service_account" {
  source = "../project_iam_service_account_roles"

  project     = var.project
  name        = "gke-default-${var.name}"
  description = "Service account for Google Kubernetes Engine cluster nodes."
  roles = [
    # Minimum roles needed by GKE
    # https://cloud.google.com/kubernetes-engine/docs/how-to/access-scopes#minimal
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    # Optional: To pull private images from Google Container Registry
    # https://cloud.google.com/kubernetes-engine/docs/how-to/access-scopes#additional_roles
    "roles/storage.objectViewer",
    # Optional: To access underlying Compute Engine nodes
    # https://cloud.google.com/kubernetes-engine/docs/how-to/access-scopes#additional_roles
    # "roles/compute.admin",
  ]
}

resource "google_container_cluster" "cluster" {
  # This resource contains blocks that requires the google-beta provider
  provider = google-beta
  project  = var.project

  # BASIC CONFIGURATION
  name = var.name
  # Zonal clusters are cheaper than regional ones but is less available
  # https://cloud.google.com/kubernetes-engine/pricing
  location = var.location
  release_channel {
    channel = "REGULAR"
  }

  # AUTOMATION CONFIGURATION
  # The time is in UTC format, which translates to 02:00SGT
  maintenance_policy {
    daily_maintenance_window {
      start_time = "18:00"
    }
  }

  # NETWORKING CONFIGURATION
  # Enable VPC-native cluster
  ip_allocation_policy {}

  # SECURITY CONFIGURATION
  # Workload identity
  # https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity#enable_workload_identity_on_a_new_cluster
  workload_identity_config {
    identity_namespace = "${var.project}.svc.id.goog"
  }
  # Enable Application-layer Secrets Encryption
  # https://cloud.google.com/kubernetes-engine/docs/how-to/encrypting-secrets
  database_encryption {
    state    = var.database_encryption_key == "" ? "DECRYPTED" : "ENCRYPTED"
    key_name = var.database_encryption_key == "" ? "" : var.database_encryption_key
  }
  # Enable Shielded GKE nodes
  # https://cloud.google.com/kubernetes-engine/docs/how-to/shielded-gke-nodes
  enable_shielded_nodes = true
  # Enable Binary Authorization
  # https://cloud.google.com/binary-authorization
  enable_binary_authorization = true

  # METADATA CONFIGURATION
  resource_labels = var.labels

  # FEATURE CONFIGURATION

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "node_pool" {
  # This resource contains blocks that requires the google-beta provider
  provider = google-beta
  project  = var.project

  for_each = var.node_pools

  # BASIC CONFIGURATION
  name     = each.key
  location = google_container_cluster.cluster.location
  cluster  = google_container_cluster.cluster.name
  # Attribute node_count cannot be used together with autoscaling
  # node_count = each.value.node_count
  initial_node_count = 1
  autoscaling {
    min_node_count = each.value.min_nodes
    max_node_count = each.value.max_nodes
  }
  management {
    auto_repair  = true
    auto_upgrade = true
  }
  # The maximum simultaneous node upgrade is the sum
  # of the following numbers
  # https://cloud.google.com/kubernetes-engine/docs/concepts/cluster-upgrades#surge
  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }

  # NODE CONFIGURATION
  node_config {

    # MACHINE CONFIGURATION
    preemptible  = true
    machine_type = each.value.machine_type
    disk_size_gb = each.value.disk_size_gb
    # Best Practice: Limit default access scopes for essential access only
    # https://cloud.google.com/kubernetes-engine/docs/how-to/hardening-your-cluster#use_least_privilege_sa
    service_account = module.google_service_account.service_account.email

    # SECURITY CONFIGURATION
    # NOTE: Access scopes may be the legacy way of granting extra privileges
    # but they are still required for some cluster-level operations.
    # https://cloud.google.com/kubernetes-engine/docs/how-to/access-scopes
    oauth_scopes = [
      # For pulling private images from Container Registry
      "https://www.googleapis.com/auth/devstorage.read_only",
      # For logging and monitoring; usually included
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      # Other remaining access scopes from the `gke-default` alias
      # https://cloud.google.com/sdk/gcloud/reference/container/node-pools/create#--scopes
      # "https://www.googleapis.com/auth/service.management.readonly",
      # "https://www.googleapis.com/auth/servicecontrol",
      # "https://www.googleapis.com/auth/trace.append",
    ]
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
    # Expose node metadata on node pool
    # NOTE: Required for Workload Identity
    # FIXME: This block needs to be explicitly defined
    # to avoid replacements due to a reported bug:
    # https://github.com/terraform-providers/terraform-provider-google/issues/5937
    workload_metadata_config {
      node_metadata = "GKE_METADATA_SERVER"
    }

    # METADATA CONFIGURATION
    labels = var.labels
    # From GKE 1.12 onwards, disable-legacy-endpoints is set to 
    # true by the API; if metadata is set but that default value 
    # is not included, Terraform will attempt to unset the value.
    # To avoid this, set the value in your config.
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}
