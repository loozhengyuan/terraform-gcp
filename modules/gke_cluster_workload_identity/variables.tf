variable "project" {
  description = "The name of the Google Cloud project."
  type        = string
}

variable "namespace" {
  description = "The name of the Kubernetes namespace to deploy to."
  type        = string
}

variable "ksa_name" {
  description = "The name of the Kubernetes Service Account."
  type        = string
}

variable "gsa_name" {
  description = "The name of the Google Service Account."
  type        = string
}
