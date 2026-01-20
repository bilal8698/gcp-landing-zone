variable "project_id" {
  description = "Producer GCP project ID"
  type        = string
}

variable "region" {
  description = "Primary region for resources"
  type        = string
}

variable "zones" {
  description = "List of zones for zonal resources"
  type        = list(string)
}

variable "vpc_network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "service_account_id" {
  description = "Service account ID"
  type        = string
}

variable "service_account_display_name" {
  description = "Service account display name"
  type        = string
}

variable "service_account_roles" {
  description = "IAM roles for service account"
  type        = list(string)
}

variable "intercept_deployment_group_name" {
  description = "Name of the intercept deployment group"
  type        = string
}

variable "intercept_deployment_group_description" {
  description = "Description of the intercept deployment group"
  type        = string
}

variable "external_user_principals" {
  description = "List of IAM principals who can use the deployment group"
  type        = list(string)
}

variable "bootstrap_buckets" {
  description = "List of bootstrap bucket configurations"
  type = list(object({
    name               = string
    location           = string
    force_destroy      = bool
    lifecycle_age_days = number
    firewall_config = object({
      hostname                    = string
      panorama_server             = string
      panorama_server2            = string
      template_name               = string
      device_group_name           = string
      op_command_modes            = string
      dns_primary                 = string
      dns_secondary               = string
      ntp_primary                 = string
      ntp_secondary               = string
      timezone                    = string
      login_banner                = string
      vm_series_auto_registration = string
    })
    labels = map(string)
  }))
}

variable "vm_auth_key" {
  description = "VM auth key for Panorama"
  type        = string
  sensitive   = true
  default     = ""
}

variable "authcodes" {
  description = "Map of license authcodes"
  type        = map(string)
  sensitive   = true
  default     = {}
}

variable "packet_inspection_vms" {
  description = "List of packet inspection VM configurations"
  type = list(object({
    name                        = string
    zone                        = string
    machine_type                = string
    target_size                 = number
    mgmt_subnet_name            = string
    data_subnet_name            = string
    mgmt_interface_has_external_ip = bool
    data_interface_has_external_ip = bool
    image                       = string
    boot_disk_size_gb           = number
    boot_disk_type              = string
    enable_autoscaling          = bool
    autoscaling_min_replicas    = number
    autoscaling_max_replicas    = number
    autoscaling_cpu_target      = number
    autoscaling_cooldown_period = number
    bootstrap_bucket_name       = string
    nlb_name                    = string
  }))
}

variable "load_balancers" {
  description = "List of internal load balancer configurations"
  type = list(object({
    name            = string
    region          = string
    zone            = string
    subnet_name     = string
    backend_protocol = string
    health_check = object({
      protocol             = string
      port                 = number
      interval_sec         = number
      timeout_sec          = number
      healthy_threshold    = number
      unhealthy_threshold  = number
    })
    enable_failover             = bool
    allow_global_access         = bool
    consumer_subnet_gateway_ips = list(string)
    vm_group_name               = string
  }))
}

variable "intercept_deployments" {
  description = "List of zonal intercept deployments"
  type = list(object({
    name        = string
    zone        = string
    description = string
    nlb_name    = string
  }))
}

variable "labels" {
  description = "Common labels for all resources"
  type        = map(string)
  default     = {}
}
