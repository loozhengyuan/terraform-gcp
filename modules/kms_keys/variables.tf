variable "project" {
  description = "The name of the Google Cloud project."
  type        = string
}

variable "location" {
  description = "The name of the regional cloud location where resources are to be deployed to."
  type        = string
}

variable "labels" {
  description = "The labels to be set on the Google Cloud resources."
  type        = map(string)

  default = {
    managed_by = "terraform"
  }
}

variable "keyring" {
  description = "The name of the Cloud KMS Crypto Key Ring."
  type        = string
}

variable "keys" {
  description = "The configuration variables for Cloud KMS Crypto Key."
  type = map(
    object(
      {
        purpose    = string
        algorithm  = string
        protection = string
      }
    )
  )
}
