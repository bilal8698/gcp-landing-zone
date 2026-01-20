output "id" {
  description = "ID of the security profile group"
  value       = google_network_security_security_profile_group.main.id
}

output "name" {
  description = "Name of the security profile group"
  value       = google_network_security_security_profile_group.main.name
}

output "self_link" {
  description = "Self link of the security profile group"
  value       = google_network_security_security_profile_group.main.self_link
}

output "location" {
  description = "Location of the security profile group"
  value       = google_network_security_security_profile_group.main.location
}
