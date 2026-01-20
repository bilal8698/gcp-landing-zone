output "intercept_deployment_group_id" {
  description = "ID of the intercept deployment group"
  value       = module.intercept_deployment_group.id
}

output "intercept_deployment_group_name" {
  description = "Name of the intercept deployment group"
  value       = module.intercept_deployment_group.name
}

output "intercept_deployment_ids" {
  description = "Map of intercept deployment names to IDs"
  value       = { for k, v in module.intercept_deployment : k => v.id }
}

output "load_balancer_ips" {
  description = "Map of load balancer names to IP addresses"
  value       = { for k, v in module.internal_nlb : k => v.forwarding_rule_ip_address }
}

output "instance_group_names" {
  description = "Map of instance group names"
  value       = { for k, v in module.packet_inspection_vms : k => v.instance_group_name }
}

output "bootstrap_bucket_names" {
  description = "Map of bootstrap bucket names"
  value       = { for k, v in module.bootstrap : k => v.bucket_name }
}

output "service_account_email" {
  description = "Service account email for Palo Alto VMs"
  value       = google_service_account.palo_alto_vm.email
}
