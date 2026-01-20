output "id" {
  description = "The ID of the intercept deployment group"
  value       = google_network_security_intercept_deployment_group.main.id
}

output "name" {
  description = "The name of the intercept deployment group"
  value       = google_network_security_intercept_deployment_group.main.name
}

output "self_link" {
  description = "The self link of the intercept deployment group"
  value       = google_network_security_intercept_deployment_group.main.self_link
}

output "location" {
  description = "The location of the intercept deployment group"
  value       = google_network_security_intercept_deployment_group.main.location
}
