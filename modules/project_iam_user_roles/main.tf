terraform {
  required_providers {
    google = "~> 3.12"
  }
}

locals {
  # Create a Cartersian product of sets in nested
  # list format.
  user_role_pairs = [
    for pair in setproduct(var.users, var.roles) : {
      user = pair[0]
      role = pair[1]
    }
  ]

  # Create a map of user-role pairs since for_each
  # only accepts sets or maps.
  user_role_mappings = {
    for pair in local.user_role_pairs : "${pair.user}:${pair.role}" => pair
  }
}

resource "google_project_iam_member" "user_role" {
  provider = google
  project  = var.project

  for_each = local.user_role_mappings

  # Role must be a valid Cloud IAM role
  role = each.value.role

  # Member must be a valid Google Account email id
  member = "user:${each.value.user}"
}
