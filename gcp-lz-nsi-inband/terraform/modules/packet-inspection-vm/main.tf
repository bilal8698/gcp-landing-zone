# Packet Inspection VM Module - Palo Alto NGFW
# Creates a zonal managed instance group with Palo Alto VM-Series firewalls

# Instance template for Palo Alto NGFW
resource "google_compute_instance_template" "palo_alto" {
  name_prefix  = "${var.name}-template-"
  project      = var.project_id
  machine_type = var.machine_type
  region       = var.region

  metadata = merge({
    serial-port-enable = "true"
    ssh-keys           = var.ssh_keys
    user-data          = var.bootstrap_bucket_url != "" ? "vmseries-bootstrap-gce-storagebucket=${var.bootstrap_bucket_url}" : null
  }, var.metadata)

  tags = concat(["packet-inspection"], var.network_tags)

  # Management interface (nic0)
  network_interface {
    subnetwork = var.mgmt_subnet_self_link
    dynamic "access_config" {
      for_each = var.mgmt_interface_has_external_ip ? [1] : []
      content {}
    }
  }

  # Data plane interface for packet inspection (nic1)
  network_interface {
    subnetwork = var.data_subnet_self_link
    dynamic "access_config" {
      for_each = var.data_interface_has_external_ip ? [1] : []
      content {}
    }
  }

  # Boot disk with Palo Alto image
  disk {
    source_image = var.palo_alto_image
    auto_delete  = true
    boot         = true
    disk_size_gb = var.boot_disk_size_gb
    disk_type    = var.boot_disk_type
  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  labels = var.labels

  lifecycle {
    create_before_destroy = true
  }
}

# Zonal managed instance group
resource "google_compute_instance_group_manager" "palo_alto" {
  name    = var.name
  project = var.project_id
  zone    = var.zone

  base_instance_name = "${var.name}-vm"
  target_size        = var.target_size

  version {
    instance_template = google_compute_instance_template.palo_alto.id
  }

  named_port {
    name = "geneve"
    port = 6081
  }

  auto_healing_policies {
    health_check      = var.health_check_self_link
    initial_delay_sec = var.auto_healing_initial_delay_sec
  }

  update_policy {
    type                         = "PROACTIVE"
    minimal_action               = "REPLACE"
    max_surge_fixed              = var.max_surge
    max_unavailable_fixed        = var.max_unavailable
    replacement_method           = "SUBSTITUTE"
    instance_redistribution_type = "PROACTIVE"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Optional: Autoscaler for the managed instance group
resource "google_compute_autoscaler" "palo_alto" {
  count   = var.enable_autoscaling ? 1 : 0
  name    = "${var.name}-autoscaler"
  project = var.project_id
  zone    = var.zone
  target  = google_compute_instance_group_manager.palo_alto.id

  autoscaling_policy {
    max_replicas    = var.autoscaling_max_replicas
    min_replicas    = var.autoscaling_min_replicas
    cooldown_period = var.autoscaling_cooldown_period

    cpu_utilization {
      target = var.autoscaling_cpu_target
    }

    dynamic "metric" {
      for_each = var.autoscaling_custom_metrics
      content {
        name   = metric.value.name
        target = metric.value.target
        type   = metric.value.type
      }
    }
  }
}
