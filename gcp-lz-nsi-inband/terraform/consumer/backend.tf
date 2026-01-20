# Backend configuration for Terraform state
# Update with your GCS bucket details

terraform {
  backend "gcs" {
    bucket = "terraform-state-nsi-consumer"
    prefix = "nsi-inband/consumer"
  }
}
