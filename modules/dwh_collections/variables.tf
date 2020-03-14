variable "project" {
  description = "The name of the Google Cloud project."
  type        = string
}

variable "location" {
  description = "The name of the regional or multi-regional cloud location where resources are to be deployed to."
  type        = string
}

variable "name" {
  description = "The name of the data collection."
  type        = string
}

variable "labels" {
  description = "The labels to be set on the Google Cloud resources."
  type        = map(string)

  default = {
    managed_by = "terraform"
  }
}

variable "gcs_days_to_nearline" {
  description = "The number of days before objects are set to NEARLINE storage class."
  type        = string
  default     = "30"
}

variable "gcs_days_to_coldline" {
  description = "The number of days before objects are set to COLDLINE storage class."
  type        = string
  default     = "90"
}

variable "gcs_versioning" {
  description = "Whether versioning is enabled on Google Cloud Storage buckets."
  type        = bool
  default     = true
}
