variable "organization_id" {
  description = "The GCP organization ID"
  type        = string
}

variable "name" {
  description = "Name of the security profile group"
  type        = string
}

variable "location" {
  description = "Location for the security profile group (use 'global' for organization-level)"
  type        = string
  default     = "global"
}

variable "description" {
  description = "Description of the security profile group"
  type        = string
  default     = "Security profile group for in-band packet inspection"
}

variable "threat_prevention_profile_id" {
  description = "ID of the threat prevention security profile"
  type        = string
}

variable "labels" {
  description = "Labels to apply to the security profile group"
  type        = map(string)
  default     = {}
}
