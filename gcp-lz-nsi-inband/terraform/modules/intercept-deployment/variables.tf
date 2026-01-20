variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "name" {
  description = "Name of the zonal intercept deployment"
  type        = string
}

variable "zone" {
  description = "Zone where the intercept deployment is created"
  type        = string
}

variable "description" {
  description = "Description of the intercept deployment"
  type        = string
  default     = "Zonal intercept deployment for packet inspection"
}

variable "intercept_deployment_group_name" {
  description = "Name of the intercept deployment group this deployment belongs to"
  type        = string
}

variable "forwarding_rule_self_link" {
  description = "Self link of the internal passthrough NLB forwarding rule"
  type        = string
}

variable "labels" {
  description = "Labels to apply to the intercept deployment"
  type        = map(string)
  default     = {}
}
