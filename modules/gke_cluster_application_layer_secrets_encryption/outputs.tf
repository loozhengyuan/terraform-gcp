output "keyring" {
  description = "The attributes of Cloud KMS Crypto Key Ring."
  value       = kms_keys.keyring
}

output "key" {
  description = "The attributes of Cloud KMS Crypto Key."
  value       = kms_keys.key
}
