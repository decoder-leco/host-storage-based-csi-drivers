terraform {
  required_providers {
    # google = {
    #   source  = "hashicorp/google"
    #   version = "5.30.0"
    # }
  }
  # specify terraform version
  # required_version = ">= 0.12.31"
  required_version = ">= 1.3.0"
}


# provider "google" {
#   project = var.gcp_project_id # "{{YOUR GCP PROJECT}}"
#   region  = var.gcp_region
#   zone    = var.gcp_zone
# }