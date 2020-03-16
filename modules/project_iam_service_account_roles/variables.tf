variable "project" {
  description = "The name of the Google Cloud project."
  type        = string
}

variable "name" {
  description = "The name of the service account."
  type        = string
}

variable "description" {
  description = "The description for the service account."
  type        = string
}

variable "description_suffix" {
  description = "The description suffix for the service account. Defaults to 'Managed by Terraform.'"
  type        = string
  default     = "Managed by Terraform."
}

variable "roles" {
  description = "The list of roles to be added to the service account."
  type        = set(string)
}
