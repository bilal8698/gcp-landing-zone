output "instance_group_id" {
  description = "ID of the managed instance group"
  value       = google_compute_instance_group_manager.palo_alto.id
}

output "instance_group_self_link" {
  description = "Self link of the managed instance group"
  value       = google_compute_instance_group_manager.palo_alto.instance_group
}

output "instance_group_name" {
  description = "Name of the managed instance group"
  value       = google_compute_instance_group_manager.palo_alto.name
}

output "instance_template_id" {
  description = "ID of the instance template"
  value       = google_compute_instance_template.palo_alto.id
}

output "instance_template_self_link" {
  description = "Self link of the instance template"
  value       = google_compute_instance_template.palo_alto.self_link
}

output "zone" {
  description = "Zone of the instance group"
  value       = google_compute_instance_group_manager.palo_alto.zone
}

output "autoscaler_id" {
  description = "ID of the autoscaler (if enabled)"
  value       = var.enable_autoscaling ? google_compute_autoscaler.palo_alto[0].id : null
}
