# Consumer Service - Main Terraform Configuration
# Configures VPCs to use producer's packet inspection services

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

# Service Account for consumer operations
resource "google_service_account" "consumer" {
  account_id   = var.service_account_id
  display_name = var.service_account_display_name
  description  = "Service account for NSI consumer operations"
  project      = var.project_id
}

# IAM roles for service account
resource "google_project_iam_member" "consumer_roles" {
  for_each = toset(var.service_account_roles)
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.consumer.email}"
}

# Intercept Endpoint Group
module "intercept_endpoint_group" {
  source = "../modules/intercept-endpoint-group"

  project_id  = var.project_id
  name        = var.intercept_endpoint_group_name
  location    = var.region
  description = var.intercept_endpoint_group_description

  producer_deployment_group_name = var.producer_deployment_group_full_name
  vpc_network_names              = var.vpc_network_names

  labels = var.labels
}

# Security Profile
module "security_profile" {
  source = "../modules/security-profile"

  organization_id = var.organization_id
  name            = var.security_profile_name
  location        = var.security_profile_location
  description     = var.security_profile_description

  severity_overrides = var.security_profile_severity_overrides
  threat_overrides   = var.security_profile_threat_overrides

  labels = var.labels
}

# Security Profile Group
module "security_profile_group" {
  source = "../modules/security-profile-group"

  organization_id = var.organization_id
  name            = var.security_profile_group_name
  location        = var.security_profile_group_location
  description     = var.security_profile_group_description

  threat_prevention_profile_id = module.security_profile.id

  labels = var.labels
}

# Firewall Policies
module "firewall_policy" {
  source   = "../modules/firewall-policy"
  for_each = { for p in var.firewall_policies : p.name => p }

  project_id    = each.value.type == "global" ? var.project_id : ""
  name          = each.value.name
  description   = each.value.description
  policy_type   = each.value.type
  policy_parent = each.value.type == "hierarchical" ? var.policy_parent : ""

  rules = [
    for rule in each.value.rules : {
      priority    = rule.priority
      action      = rule.action
      description = rule.description
      direction   = rule.direction
      disabled    = lookup(rule, "disabled", false)
      match       = rule.match
      security_profile_group_name = rule.action == "apply_security_profile_group" ? module.security_profile_group.name : ""
      target_resources            = lookup(rule, "target_resources", [])
    }
  ]

  vpc_networks = each.value.type == "global" ? each.value.vpc_networks : []

  depends_on = [module.security_profile_group]
}
