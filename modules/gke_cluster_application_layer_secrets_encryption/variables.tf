variable "project" {
  description = "The name of the Google Cloud project."
  type        = string
}

variable "location" {
  description = "The name of the regional (not zone) cloud location where resources are to be deployed to."
  type        = string
}

variable "name" {
  description = "The name of the Kubernetes Engine cluster."
  type        = string
}
