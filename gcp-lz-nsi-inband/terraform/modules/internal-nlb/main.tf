# Internal Passthrough Network Load Balancer Module
# Creates an internal NLB for GENEVE-encapsulated traffic (UDP:6081)

# Backend service with instance group
resource "google_compute_region_backend_service" "main" {
  name    = var.name
  project = var.project_id
  region  = var.region

  protocol              = var.backend_protocol
  load_balancing_scheme = "INTERNAL"
  network               = var.network_self_link

  health_checks = [var.health_check_self_link]

  dynamic "backend" {
    for_each = var.instance_groups
    content {
      group          = backend.value.self_link
      balancing_mode = "CONNECTION"
    }
  }

  connection_draining_timeout_sec = var.connection_draining_timeout_sec
  session_affinity                = var.session_affinity

  # Failover configuration for high availability
  dynamic "failover_policy" {
    for_each = var.enable_failover ? [1] : []
    content {
      disable_connection_drain_on_failover = false
      drop_traffic_if_unhealthy            = true
      failover_ratio                       = 0.3
    }
  }
}

# Forwarding rule for GENEVE traffic (UDP:6081)
resource "google_compute_forwarding_rule" "main" {
  name    = "${var.name}-forwarding-rule"
  project = var.project_id
  region  = var.region

  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.main.id
  
  ip_protocol = "UDP"
  ports       = ["6081"]  # GENEVE encapsulation port
  
  network    = var.network_self_link
  subnetwork = var.subnetwork_self_link

  # Allow global access for cross-region traffic
  allow_global_access = var.allow_global_access

  labels = var.labels
}

# Firewall rule to allow GENEVE traffic from consumer subnets
resource "google_compute_firewall" "geneve" {
  name    = "${var.name}-allow-geneve"
  project = var.project_id
  network = var.network_name

  description = "Allow GENEVE encapsulated traffic (UDP:6081) from consumer subnet gateways"

  allow {
    protocol = "udp"
    ports    = ["6081"]
  }

  source_ranges = var.consumer_subnet_gateway_ips

  target_tags = var.target_tags
}
