terraform {
  required_providers {
    google = "~> 3.12"
  }
}

locals {
  keyring_name = "gke-encryption-keys"
  key_name     = "${var.cluster}-kek"
}

data "google_project" "project" {
  project_id = var.project
}

module "kms_keys" {
  source = "../kms_keys"

  project  = var.project
  location = var.location # Must be same region as cluster
  keyring  = local.keyring_name
  keys = {
    local.key_name = {
      # Symmetric encryption keys
      purpose    = "ENCRYPT_DECRYPT"
      algorithm  = "GOOGLE_SYMMETRIC_ENCRYPTION"
      protection = "SOFTWARE"
    }
  }
}

data "google_iam_policy" "admin" {
  binding {
    role = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

    members = [
      "serviceAccount:service-${data.google_project.project.number}@container-engine-robot.iam.gserviceaccount.com",
    ]
  }
}

resource "google_kms_crypto_key_iam_policy" "crypto_key" {
  crypto_key_id = module.kms_keys.key[local.key_name].id
  policy_data   = data.google_iam_policy.admin.policy_data
}
