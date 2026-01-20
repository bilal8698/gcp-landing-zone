output "backend_service_id" {
  description = "ID of the backend service"
  value       = google_compute_region_backend_service.main.id
}

output "backend_service_self_link" {
  description = "Self link of the backend service"
  value       = google_compute_region_backend_service.main.self_link
}

output "forwarding_rule_id" {
  description = "ID of the forwarding rule"
  value       = google_compute_forwarding_rule.main.id
}

output "forwarding_rule_self_link" {
  description = "Self link of the forwarding rule"
  value       = google_compute_forwarding_rule.main.self_link
}

output "forwarding_rule_ip_address" {
  description = "IP address of the forwarding rule"
  value       = google_compute_forwarding_rule.main.ip_address
}

output "health_check_id" {
  description = "ID of the health check"
  value       = google_compute_health_check.main.id
}

output "health_check_self_link" {
  description = "Self link of the health check"
  value       = google_compute_health_check.main.self_link
}
