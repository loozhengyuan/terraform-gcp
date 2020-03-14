variable "project" {
  description = "The name of the Google Cloud project."
  type        = string
}

variable "email" {
  description = "The email of the Google account."
  type        = string
}

variable "roles" {
  description = "The list of roles to be added to the user."
  type        = set(string)
}
