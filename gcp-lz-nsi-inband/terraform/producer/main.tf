# Producer Service - Main Terraform Configuration
# Deploys NSI in-band packet inspection infrastructure

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# Service Account for Palo Alto VMs
resource "google_service_account" "palo_alto_vm" {
  account_id   = var.service_account_id
  display_name = var.service_account_display_name
  description  = "Service account for Palo Alto NGFW VMs"
  project      = var.project_id
}

# IAM roles for service account
resource "google_project_iam_member" "palo_alto_vm_roles" {
  for_each = toset(var.service_account_roles)
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.palo_alto_vm.email}"
}

# Bootstrap buckets
module "bootstrap" {
  source   = "../modules/bootstrap"
  for_each = { for b in var.bootstrap_buckets : b.name => b }

  project_id            = var.project_id
  bucket_name           = each.value.name
  location              = each.value.location
  force_destroy         = each.value.force_destroy
  lifecycle_age_days    = each.value.lifecycle_age_days
  service_account_email = google_service_account.palo_alto_vm.email

  hostname                    = each.value.firewall_config.hostname
  panorama_server             = each.value.firewall_config.panorama_server
  panorama_server2            = each.value.firewall_config.panorama_server2
  template_name               = each.value.firewall_config.template_name
  device_group_name           = each.value.firewall_config.device_group_name
  vm_auth_key                 = var.vm_auth_key
  op_command_modes            = each.value.firewall_config.op_command_modes
  dns_primary                 = each.value.firewall_config.dns_primary
  dns_secondary               = each.value.firewall_config.dns_secondary
  ntp_primary                 = each.value.firewall_config.ntp_primary
  ntp_secondary               = each.value.firewall_config.ntp_secondary
  timezone                    = each.value.firewall_config.timezone
  login_banner                = each.value.firewall_config.login_banner
  vm_series_auto_registration = each.value.firewall_config.vm_series_auto_registration

  authcodes = var.authcodes
  labels    = merge(var.labels, each.value.labels)
}

# Intercept Deployment Group
module "intercept_deployment_group" {
  source = "../modules/intercept-deployment-group"

  project_id  = var.project_id
  name        = var.intercept_deployment_group_name
  location    = var.region
  description = var.intercept_deployment_group_description

  external_user_principals = var.external_user_principals

  labels = var.labels
}

# Packet Inspection VMs (Managed Instance Groups)
module "packet_inspection_vms" {
  source   = "../modules/packet-inspection-vm"
  for_each = { for vm in var.packet_inspection_vms : vm.name => vm }

  project_id = var.project_id
  name       = each.value.name
  region     = var.region
  zone       = each.value.zone

  machine_type      = each.value.machine_type
  palo_alto_image   = each.value.image
  boot_disk_size_gb = each.value.boot_disk_size_gb
  boot_disk_type    = each.value.boot_disk_type

  mgmt_subnet_self_link = "projects/${var.project_id}/regions/${var.region}/subnetworks/${each.value.mgmt_subnet_name}"
  data_subnet_self_link = "projects/${var.project_id}/regions/${var.region}/subnetworks/${each.value.data_subnet_name}"

  mgmt_interface_has_external_ip = each.value.mgmt_interface_has_external_ip
  data_interface_has_external_ip = each.value.data_interface_has_external_ip

  service_account_email = google_service_account.palo_alto_vm.email
  bootstrap_bucket_url  = module.bootstrap[each.value.bootstrap_bucket_name].bucket_url

  target_size                   = each.value.target_size
  health_check_self_link        = module.internal_nlb[each.value.nlb_name].health_check_self_link
  auto_healing_initial_delay_sec = 600

  enable_autoscaling          = each.value.enable_autoscaling
  autoscaling_min_replicas    = each.value.autoscaling_min_replicas
  autoscaling_max_replicas    = each.value.autoscaling_max_replicas
  autoscaling_cpu_target      = each.value.autoscaling_cpu_target
  autoscaling_cooldown_period = each.value.autoscaling_cooldown_period

  labels = var.labels
}

# Internal Passthrough Network Load Balancers
module "internal_nlb" {
  source   = "../modules/internal-nlb"
  for_each = { for lb in var.load_balancers : lb.name => lb }

  project_id = var.project_id
  name       = each.value.name
  region     = each.value.region

  network_self_link    = "projects/${var.project_id}/global/networks/${var.vpc_network_name}"
  network_name         = var.vpc_network_name
  subnetwork_self_link = "projects/${var.project_id}/regions/${each.value.region}/subnetworks/${each.value.subnet_name}"

  backend_protocol = each.value.backend_protocol

  instance_groups = [
    {
      self_link = module.packet_inspection_vms[each.value.vm_group_name].instance_group_self_link
    }
  ]

  health_check_protocol          = each.value.health_check.protocol
  health_check_port              = each.value.health_check.port
  health_check_interval_sec      = each.value.health_check.interval_sec
  health_check_timeout_sec       = each.value.health_check.timeout_sec
  health_check_healthy_threshold = each.value.health_check.healthy_threshold
  health_check_unhealthy_threshold = each.value.health_check.unhealthy_threshold

  enable_failover     = each.value.enable_failover
  allow_global_access = each.value.allow_global_access

  consumer_subnet_gateway_ips = each.value.consumer_subnet_gateway_ips

  labels = var.labels
}

# Zonal Intercept Deployments
module "intercept_deployment" {
  source   = "../modules/intercept-deployment"
  for_each = { for d in var.intercept_deployments : d.name => d }

  project_id  = var.project_id
  name        = each.value.name
  zone        = each.value.zone
  description = each.value.description

  intercept_deployment_group_name = module.intercept_deployment_group.name
  forwarding_rule_self_link       = module.internal_nlb[each.value.nlb_name].forwarding_rule_self_link

  labels = var.labels

  depends_on = [module.intercept_deployment_group, module.internal_nlb]
}
