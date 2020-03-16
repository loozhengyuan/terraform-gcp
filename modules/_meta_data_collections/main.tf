terraform {
  required_providers {
    google = "~> 3.12"
  }
}

locals {
  collection_names = set(
    [
      for name in var.names : "${var.collection_prefix}${name}${var.collection_suffix}"
    ]
  )
}

resource "google_bigquery_dataset" "dataset" {
  provider = google
  project  = var.project

  for_each = local.collection_names

  dataset_id = each.value
  location   = var.location

  # Using partition expiration only affects table
  # that were created when this field is set. Moreover,
  # when DATE is used as the partition field, one cannot
  # insert any data outside of the expiration window.
  # default_partition_expiration_ms = 63072000000 # 2 years

  labels = {
    managed_by = "terraform"
  }
}

resource "google_storage_bucket" "bucket" {
  provider = google
  project  = var.project

  for_each = local.collection_names

  name               = each.value
  location           = var.location
  storage_class      = "STANDARD"
  bucket_policy_only = "true"

  labels = {
    managed_by = "terraform"
  }

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
    condition {
      age = 30
    }
  }

  lifecycle_rule {
    action {
      type          = "SetStorageClass"
      storage_class = "COLDLINE"
    }
    condition {
      age = 90
    }
  }
}
