variable "organization_id" {
  description = "The GCP organization ID"
  type        = string
}

variable "name" {
  description = "Name of the security profile"
  type        = string
}

variable "location" {
  description = "Location for the security profile (use 'global' for organization-level)"
  type        = string
  default     = "global"
}

variable "description" {
  description = "Description of the security profile"
  type        = string
  default     = "Custom intercept security profile for in-band inspection"
}

variable "severity_overrides" {
  description = "List of severity level overrides"
  type = list(object({
    action   = string # ALLOW, ALERT, DENY
    severity = string # INFORMATIONAL, LOW, MEDIUM, HIGH, CRITICAL
  }))
  default = [
    {
      action   = "ALLOW"
      severity = "INFORMATIONAL"
    },
    {
      action   = "ALLOW"
      severity = "LOW"
    },
    {
      action   = "ALERT"
      severity = "MEDIUM"
    },
    {
      action   = "DENY"
      severity = "HIGH"
    },
    {
      action   = "DENY"
      severity = "CRITICAL"
    }
  ]
}

variable "threat_overrides" {
  description = "List of specific threat ID overrides"
  type = list(object({
    action    = string # ALLOW, ALERT, DENY
    threat_id = string
  }))
  default = []
}

variable "labels" {
  description = "Labels to apply to the security profile"
  type        = map(string)
  default     = {}
}
