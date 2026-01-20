variable "project_id" {
  description = "The GCP project ID (for global policies)"
  type        = string
  default     = ""
}

variable "name" {
  description = "Name of the firewall policy"
  type        = string
}

variable "description" {
  description = "Description of the firewall policy"
  type        = string
  default     = "Firewall policy for NSI in-band inspection"
}

variable "policy_type" {
  description = "Type of firewall policy: 'hierarchical' or 'global'"
  type        = string
  validation {
    condition     = contains(["hierarchical", "global"], var.policy_type)
    error_message = "Policy type must be 'hierarchical' or 'global'"
  }
}

variable "policy_parent" {
  description = "Parent for hierarchical policy (organizations/ORG_ID or folders/FOLDER_ID)"
  type        = string
  default     = ""
}

variable "rules" {
  description = "List of firewall policy rules"
  type = list(object({
    priority    = number
    action      = string # apply_security_profile_group, allow, deny
    description = string
    direction   = string # INGRESS or EGRESS
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
}

variable "vpc_networks" {
  description = "List of VPC network names to associate with this policy (for global policies)"
  type        = list(string)
  default     = []
}
