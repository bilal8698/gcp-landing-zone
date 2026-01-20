output "intercept_endpoint_group_id" {
  description = "ID of the intercept endpoint group"
  value       = module.intercept_endpoint_group.endpoint_group_id
}

output "intercept_endpoint_group_name" {
  description = "Name of the intercept endpoint group"
  value       = module.intercept_endpoint_group.endpoint_group_name
}

output "security_profile_id" {
  description = "ID of the security profile"
  value       = module.security_profile.id
}

output "security_profile_name" {
  description = "Name of the security profile"
  value       = module.security_profile.name
}

output "security_profile_group_id" {
  description = "ID of the security profile group"
  value       = module.security_profile_group.id
}

output "security_profile_group_name" {
  description = "Name of the security profile group"
  value       = module.security_profile_group.name
}

output "firewall_policy_ids" {
  description = "Map of firewall policy names to IDs"
  value       = { for k, v in module.firewall_policy : k => v.policy_id }
}

output "service_account_email" {
  description = "Service account email for consumer operations"
  value       = google_service_account.consumer.email
}

output "endpoint_group_associations" {
  description = "VPC network associations for endpoint group"
  value       = module.intercept_endpoint_group.associations
}
