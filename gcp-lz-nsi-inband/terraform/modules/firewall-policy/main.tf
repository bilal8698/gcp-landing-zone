# Firewall Policy Module
# Creates hierarchical or global network firewall policies with NSI rules

# Firewall policy (hierarchical or global)
resource "google_compute_network_firewall_policy" "main" {
  count = var.policy_type == "global" ? 1 : 0

  name        = var.name
  project     = var.project_id
  description = var.description
}

resource "google_compute_organization_security_policy" "main" {
  count = var.policy_type == "hierarchical" ? 1 : 0

  display_name = var.name
  parent       = var.policy_parent
  description  = var.description
}

# Firewall policy rules
resource "google_compute_network_firewall_policy_rule" "rules" {
  for_each = var.policy_type == "global" ? { for r in var.rules : r.priority => r } : {}

  firewall_policy = google_compute_network_firewall_policy.main[0].name
  project         = var.project_id
  priority        = each.value.priority
  action          = each.value.action
  description     = each.value.description
  direction       = each.value.direction
  disabled        = lookup(each.value, "disabled", false)

  match {
    src_ip_ranges  = lookup(each.value.match, "src_ip_ranges", [])
    dest_ip_ranges = lookup(each.value.match, "dest_ip_ranges", [])

    dynamic "layer4_configs" {
      for_each = lookup(each.value.match, "layer4_configs", [])
      content {
        ip_protocol = layer4_configs.value.ip_protocol
        ports       = lookup(layer4_configs.value, "ports", [])
      }
    }
  }

  # For NSI rules with apply_security_profile_group action
  dynamic "security_profile_group" {
    for_each = each.value.action == "apply_security_profile_group" ? [1] : []
    content {
      name = each.value.security_profile_group_name
    }
  }

  # Target resources (VPC networks for hierarchical policies)
  target_resources = lookup(each.value, "target_resources", [])
}

resource "google_compute_organization_security_policy_rule" "rules" {
  for_each = var.policy_type == "hierarchical" ? { for r in var.rules : r.priority => r } : {}

  policy_id   = google_compute_organization_security_policy.main[0].id
  priority    = each.value.priority
  action      = each.value.action
  description = each.value.description
  direction   = each.value.direction

  match {
    config {
      src_ip_ranges  = lookup(each.value.match, "src_ip_ranges", [])
      dest_ip_ranges = lookup(each.value.match, "dest_ip_ranges", [])

      dynamic "layer4_config" {
        for_each = lookup(each.value.match, "layer4_configs", [])
        content {
          ip_protocol = layer4_config.value.ip_protocol
          ports       = lookup(layer4_config.value, "ports", [])
        }
      }
    }
  }

  # For NSI rules with apply_security_profile_group action
  dynamic "security_profile_group" {
    for_each = each.value.action == "apply_security_profile_group" ? [1] : []
    content {
      security_profile_group = each.value.security_profile_group_name
    }
  }

  # Target resources for hierarchical policies
  target_resources = lookup(each.value, "target_resources", [])
}

# Associate the policy with VPC networks (for global policies)
resource "google_compute_network_firewall_policy_association" "main" {
  for_each = var.policy_type == "global" ? toset(var.vpc_networks) : toset([])

  name              = "${var.name}-${each.value}"
  attachment_target = "projects/${var.project_id}/global/networks/${each.value}"
  firewall_policy   = google_compute_network_firewall_policy.main[0].name
  project           = var.project_id
}

# Update VPC network firewall policy enforcement order
resource "google_compute_network" "vpc_enforcement_order" {
  for_each = toset(var.vpc_networks)

  name    = each.value
  project = var.project_id

  # Set firewall policy enforcement order to BEFORE_CLASSIC_FIREWALL
  network_firewall_policy_enforcement_order = "BEFORE_CLASSIC_FIREWALL"

  # This assumes the VPC already exists; we're just updating the enforcement order
  lifecycle {
    ignore_changes = [
      routing_mode,
      auto_create_subnetworks,
      mtu,
      description,
    ]
  }
}
