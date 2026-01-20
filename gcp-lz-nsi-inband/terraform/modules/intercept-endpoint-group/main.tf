# Intercept Endpoint Group Module
# Creates an intercept endpoint group that references a producer's deployment group

resource "google_network_security_intercept_endpoint_group" "main" {
  name     = var.name
  location = var.location
  project  = var.project_id

  description = var.description

  # Reference to the producer's intercept deployment group
  intercept_deployment_group = var.producer_deployment_group_name

  labels = var.labels

  lifecycle {
    create_before_destroy = true
  }
}

# Intercept endpoint group association - associates the endpoint group with consumer VPC networks
resource "google_network_security_intercept_endpoint_group_association" "main" {
  for_each = toset(var.vpc_network_names)

  name     = "${var.name}-${each.value}-association"
  location = var.location
  project  = var.project_id

  intercept_endpoint_group = google_network_security_intercept_endpoint_group.main.id
  network                  = "projects/${var.project_id}/global/networks/${each.value}"

  labels = var.labels

  lifecycle {
    create_before_destroy = true
  }
}
