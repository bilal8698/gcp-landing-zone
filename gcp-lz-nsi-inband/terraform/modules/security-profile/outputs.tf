output "id" {
  description = "ID of the security profile"
  value       = google_network_security_security_profile.main.id
}

output "name" {
  description = "Name of the security profile"
  value       = google_network_security_security_profile.main.name
}

output "self_link" {
  description = "Self link of the security profile"
  value       = google_network_security_security_profile.main.self_link
}

output "location" {
  description = "Location of the security profile"
  value       = google_network_security_security_profile.main.location
}
