terraform {
  required_providers {
    google = "~> 3.12"
  }
}

locals {
  collection_names = toset(
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

  # Enable object versioning
  versioning {
    enabled = true
  }

  # Delete noncurrent objects if created more than 14 days ago
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age        = 14
      with_state = "ARCHIVED"
    }
  }

  # NOTE: Lifecycle policies for setting storage classes were
  # removed because the retrieval patterns and associated costs
  # make the 'archival' storage classes a more costly option.
}
