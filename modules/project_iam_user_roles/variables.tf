variable "project" {
  description = "The name of the Google Cloud project."
  type        = string
}

variable "users" {
  description = "The list of valid Google Account email addresses to be associated with the roles."
  type        = set(string)
}

variable "roles" {
  description = "The list of valid Cloud IAM roles to be granted to each user."
  type        = set(string)
}
