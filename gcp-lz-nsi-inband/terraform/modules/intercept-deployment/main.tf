# Zonal Intercept Deployment Module
# Creates a zonal intercept deployment that references an internal passthrough NLB

resource "google_network_security_intercept_deployment" "main" {
  name     = var.name
  location = var.zone
  project  = var.project_id

  description = var.description

  # Reference to the intercept deployment group
  intercept_deployment_group = var.intercept_deployment_group_name

  # Reference to the internal passthrough Network Load Balancer forwarding rule
  forwarding_rule = var.forwarding_rule_self_link

  labels = var.labels

  lifecycle {
    create_before_destroy = true
  }
}
