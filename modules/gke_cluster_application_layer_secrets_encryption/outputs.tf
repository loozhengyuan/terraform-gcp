output "keyring" {
  description = "The attributes of Cloud KMS Crypto Key Ring."
  value       = module.kms_keys.keyring
}

output "key" {
  description = "The attributes of Cloud KMS Crypto Key."
  value       = module.kms_keys.key
}
