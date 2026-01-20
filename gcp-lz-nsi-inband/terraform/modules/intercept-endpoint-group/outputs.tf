output "endpoint_group_id" {
  description = "ID of the intercept endpoint group"
  value       = google_network_security_intercept_endpoint_group.main.id
}

output "endpoint_group_name" {
  description = "Name of the intercept endpoint group"
  value       = google_network_security_intercept_endpoint_group.main.name
}

output "endpoint_group_self_link" {
  description = "Self link of the intercept endpoint group"
  value       = google_network_security_intercept_endpoint_group.main.self_link
}

output "associations" {
  description = "Map of VPC network associations"
  value = {
    for k, v in google_network_security_intercept_endpoint_group_association.main : k => {
      id        = v.id
      name      = v.name
      self_link = v.self_link
    }
  }
}
