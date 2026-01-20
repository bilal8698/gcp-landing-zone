# Backend configuration for Terraform state
# Update with your GCS bucket details

terraform {
  backend "gcs" {
    bucket = "terraform-state-nsi-producer"
    prefix = "nsi-inband/producer"
  }
}
