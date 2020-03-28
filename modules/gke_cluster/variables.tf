variable "project" {
  description = "The name of the Google Cloud project."
  type        = string
}

variable "location" {
  description = "The name of the regional or zonal cloud location where resources are to be deployed to."
  type        = string
}

variable "name" {
  description = "The name of the Kubernetes Engine cluster."
  type        = string
}

variable "labels" {
  description = "The labels to be set on the Google Cloud resources."
  type        = map(string)

  default = {
    managed_by = "terraform"
  }
}

variable "database_encryption_key" {
  description = "The fully-qualified name of Cloud KMS key."
  type        = string
  default     = ""
}

variable "node_pools" {
  description = "The configuration variables for each node pool"
  type = map(
    object(
      {
        machine_type = string
        disk_size_gb = number
        min_nodes    = number
        max_nodes    = number
      }
    )
  )
  default = {
    default-pool = {
      machine_type = "e2-small"
      disk_size_gb = 100
      min_nodes    = 1
      max_nodes    = 10
    }
  }
}
