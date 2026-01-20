output "id" {
  description = "The ID of the intercept deployment"
  value       = google_network_security_intercept_deployment.main.id
}

output "name" {
  description = "The name of the intercept deployment"
  value       = google_network_security_intercept_deployment.main.name
}

output "self_link" {
  description = "The self link of the intercept deployment"
  value       = google_network_security_intercept_deployment.main.self_link
}

output "zone" {
  description = "The zone of the intercept deployment"
  value       = google_network_security_intercept_deployment.main.location
}
