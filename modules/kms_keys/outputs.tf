output "keyring" {
  value       = google_kms_key_ring.keyring
  description = "The attributes of Cloud KMS Crypto Key Ring."
}

output "key" {
  value       = google_kms_crypto_key.key
  description = "The attributes of Cloud KMS Crypto Key."
}
