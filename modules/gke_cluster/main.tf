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

resource "google_container_cluster" "cluster" {
  # This resouce contains blocks that requires the google-beta provider
  provider = google-beta
  project  = var.project

  name = var.name

  # Zonal cluster, though not recommended, requires lesser nodes
  location = var.location

  resource_labels = var.labels

  # Requires `google-beta` provider
  release_channel {
    channel = "REGULAR"
  }

  # The time is in UTC format, which translates to 02:00SGT
  maintenance_policy {
    daily_maintenance_window {
      start_time = "18:00"
    }
  }

  # Enable VPC-native cluster
  ip_allocation_policy {}

  # Workload identity
  # https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity#enable_workload_identity_on_a_new_cluster
  workload_identity_config {
    identity_namespace = "${var.project}.svc.id.goog"
  }

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "node_pool" {
  provider = google
  project  = var.project

  for_each = var.node_pools

  name       = each.value.name
  location   = var.location
  cluster    = google_container_cluster.cluster.name
  node_count = each.value.node_count

  autoscaling {
    min_node_count = 1
    max_node_count = 30
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    preemptible  = true
    machine_type = each.value.machine_type

    labels = var.labels

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    # From GKE 1.12 onwards, disable-legacy-endpoints is set to 
    # true by the API; if metadata is set but that default value 
    # is not included, Terraform will attempt to unset the value.
    # To avoid this, set the value in your config.
    metadata = {
      disable-legacy-endpoints = "true"
    }

    # The following oauth scopes references the `gke-default` alias
    # https://cloud.google.com/sdk/gcloud/reference/container/node-pools/create#--scopes
    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append",
    ]
  }
}
