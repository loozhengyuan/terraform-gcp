terraform {
  required_providers {
    google = "~> 3.12"
  }
}

# Ensures that Cloud KMS API is enabled
resource "google_project_service" "cloudkms" {
  project = var.project
  service = "cloudkms.googleapis.com"

  # Ensures that this resource block will only
  # be concerned with enabling this API if disabled
  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_kms_key_ring" "keyring" {
  provider = google
  project  = var.project

  name     = var.keyring
  location = var.location
}

resource "google_kms_crypto_key" "key" {
  provider = google
  # Project argument not expected
  # project  = var.project

  for_each = var.keys

  name     = each.key
  key_ring = google_kms_key_ring.keyring.self_link
  labels   = var.labels
  # NOTE: Automatic key rotation with GKE ALSE is not supported
  # https://cloud.google.com/kubernetes-engine/docs/how-to/encrypting-secrets#key_rotation
  # rotation_period = "86400s"

  # The immutable purpose of the key
  # https://cloud.google.com/kms/docs/reference/rest/v1/projects.locations.keyRings.cryptoKeys#CryptoKeyPurpose
  purpose = each.value.purpose

  # Template for new keys
  version_template {
    # Set algorithm
    # https://cloud.google.com/kms/docs/reference/rest/v1/CryptoKeyVersionAlgorithm
    algorithm = each.value.algorithm

    # Set protection level
    # https://cloud.google.com/kms/docs/reference/rest/v1/ProtectionLevel
    protection_level = each.value.protection
  }

  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = true
  }
}
