terraform {
  required_providers {
    google = "~> 3.12"
  }
}

resource "google_bigquery_dataset" "dataset" {
  provider = google
  project  = var.project

  dataset_id = var.name
  location   = var.location

  # Using partition expiration only affects table
  # that were created when this field is set. Moreover,
  # when DATE is used as the partition field, one cannot
  # insert any data outside of the expiration window.
  # default_partition_expiration_ms = 63072000000 # 2 years

  labels = var.labels
}

resource "google_storage_bucket" "bucket" {
  provider = google
  project  = var.project

  name               = var.name
  location           = var.location
  storage_class      = "STANDARD"
  bucket_policy_only = "true"

  labels = var.labels

  versioning {
    enabled = var.gcs_versioning
  }

  lifecycle_rule {
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
    condition {
      age = var.gcs_days_to_nearline
    }
  }

  lifecycle_rule {
    action {
      type          = "SetStorageClass"
      storage_class = "COLDLINE"
    }
    condition {
      age = var.gcs_days_to_coldline
    }
  }
}
