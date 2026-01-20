# Intercept Deployment Group Module
# Creates a regional intercept deployment group for managing packet inspection services

resource "google_network_security_intercept_deployment_group" "main" {
  name        = var.name
  location    = var.location
  project     = var.project_id
  description = var.description

  labels = var.labels

  lifecycle {
    create_before_destroy = true
  }
}

# IAM binding to grant external users access to this deployment group
resource "google_project_iam_member" "external_users" {
  for_each = toset(var.external_user_principals)

  project = var.project_id
  role    = "roles/networksecurity.interceptDeploymentExternalUser"
  member  = each.value
}
