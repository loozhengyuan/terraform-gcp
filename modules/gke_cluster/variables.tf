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

variable "node_pool_name" {
  description = "The name of the default node pool."
  type        = string
}

variable "node_pool_machine_type" {
  description = "The machine type of the default node pool."
  type        = string
}

variable "node_pool_node_count" {
  description = "The node count of the default node pool."
  type        = number
  default     = 1
}
