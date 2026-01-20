output "policy_id" {
  description = "ID of the firewall policy"
  value       = var.policy_type == "global" ? google_compute_network_firewall_policy.main[0].id : google_compute_organization_security_policy.main[0].id
}

output "policy_name" {
  description = "Name of the firewall policy"
  value       = var.name
}

output "policy_self_link" {
  description = "Self link of the firewall policy"
  value       = var.policy_type == "global" ? google_compute_network_firewall_policy.main[0].self_link : google_compute_organization_security_policy.main[0].self_link
}

output "rule_ids" {
  description = "Map of rule priorities to rule IDs"
  value = var.policy_type == "global" ? {
    for k, v in google_compute_network_firewall_policy_rule.rules : k => v.id
    } : {
    for k, v in google_compute_organization_security_policy_rule.rules : k => v.id
  }
}

output "associations" {
  description = "Map of VPC network associations (for global policies)"
  value = {
    for k, v in google_compute_network_firewall_policy_association.main : k => {
      id        = v.id
      name      = v.name
      self_link = v.self_link
    }
  }
}
