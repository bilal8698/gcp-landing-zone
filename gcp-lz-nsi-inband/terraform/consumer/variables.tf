variable "project_id" {
  description = "Consumer GCP project ID"
  type        = string
}

variable "organization_id" {
  description = "GCP Organization ID"
  type        = string
}

variable "region" {
  description = "Primary region"
  type        = string
}

variable "service_account_id" {
  description = "Service account ID"
  type        = string
}

variable "service_account_display_name" {
  description = "Service account display name"
  type        = string
}

variable "service_account_roles" {
  description = "IAM roles for service account"
  type        = list(string)
}

variable "producer_project_id" {
  description = "Producer project ID"
  type        = string
}

variable "producer_deployment_group_name" {
  description = "Name of producer's deployment group"
  type        = string
}

variable "producer_deployment_group_location" {
  description = "Location of producer's deployment group"
  type        = string
}

variable "producer_deployment_group_full_name" {
  description = "Full resource name of producer's deployment group"
  type        = string
}

variable "vpc_network_names" {
  description = "List of VPC network names"
  type        = list(string)
}

variable "intercept_endpoint_group_name" {
  description = "Name of intercept endpoint group"
  type        = string
}

variable "intercept_endpoint_group_description" {
  description = "Description of intercept endpoint group"
  type        = string
}

variable "security_profile_name" {
  description = "Name of security profile"
  type        = string
}

variable "security_profile_location" {
  description = "Location of security profile"
  type        = string
  default     = "global"
}

variable "security_profile_description" {
  description = "Description of security profile"
  type        = string
}

variable "security_profile_severity_overrides" {
  description = "Security profile severity overrides"
  type = list(object({
    action   = string
    severity = string
  }))
}

variable "security_profile_threat_overrides" {
  description = "Security profile threat overrides"
  type = list(object({
    action    = string
    threat_id = string
  }))
  default = []
}

variable "security_profile_group_name" {
  description = "Name of security profile group"
  type        = string
}

variable "security_profile_group_location" {
  description = "Location of security profile group"
  type        = string
  default     = "global"
}

variable "security_profile_group_description" {
  description = "Description of security profile group"
  type        = string
}

variable "policy_parent" {
  description = "Parent for hierarchical policies (organizations/ORG_ID or folders/FOLDER_ID)"
  type        = string
  default     = ""
}

variable "firewall_policies" {
  description = "List of firewall policy configurations"
  type = list(object({
    name         = string
    type         = string
    description  = string
    vpc_networks = list(string)
    rules = list(object({
      priority    = number
      action      = string
      description = string
      direction   = string
      disabled    = optional(bool, false)
      match = object({
        src_ip_ranges  = optional(list(string), [])
        dest_ip_ranges = optional(list(string), [])
        layer4_configs = optional(list(object({
          ip_protocol = string
          ports       = optional(list(string), [])
        })), [])
      })
      security_profile_group_name = optional(string, "")
      target_resources            = optional(list(string), [])
    }))
  }))
}

variable "labels" {
  description = "Common labels for all resources"
  type        = map(string)
  default     = {}
}
