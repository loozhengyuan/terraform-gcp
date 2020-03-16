variable "project" {
  description = "The name of the Google Cloud project."
  type        = string
}

variable "location" {
  description = "The name of the regional or multi-regional cloud location where resources are to be deployed to."
  type        = string
}

variable "collection_prefix" {
  description = "[Optional] The prefix to be added to all collection names (including delimiter)."
  type        = string
  default     = ""
}

variable "collection_suffix" {
  description = "[Optional] The suffix to be added to all collection names (including delimiter)."
  type        = string
  default     = ""
}

variable "names" {
  description = "The set of data collection names."
  type        = set(string)
}
