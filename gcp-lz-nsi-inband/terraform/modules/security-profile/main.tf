# Security Profile Module
# Creates a custom intercept security profile for traffic inspection

resource "google_network_security_security_profile" "main" {
  name     = var.name
  type     = "THREAT_PREVENTION"
  parent   = "organizations/${var.organization_id}"
  location = var.location

  description = var.description

  labels = var.labels

  # Threat prevention profile configuration
  threat_prevention_profile {
    # Severity levels: INFORMATIONAL, LOW, MEDIUM, HIGH, CRITICAL
    dynamic "severity_overrides" {
      for_each = var.severity_overrides
      content {
        action   = severity_overrides.value.action
        severity = severity_overrides.value.severity
      }
    }

    # Threat overrides for specific threat IDs
    dynamic "threat_overrides" {
      for_each = var.threat_overrides
      content {
        action    = threat_overrides.value.action
        threat_id = threat_overrides.value.threat_id
      }
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
