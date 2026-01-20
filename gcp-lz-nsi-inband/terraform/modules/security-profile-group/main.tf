# Security Profile Group Module
# Groups multiple security profiles for use in firewall policies

resource "google_network_security_security_profile_group" "main" {
  name     = var.name
  parent   = "organizations/${var.organization_id}"
  location = var.location

  description = var.description

  # Reference to the intercept endpoint group
  threat_prevention_profile = var.threat_prevention_profile_id

  labels = var.labels

  lifecycle {
    create_before_destroy = true
  }
}
