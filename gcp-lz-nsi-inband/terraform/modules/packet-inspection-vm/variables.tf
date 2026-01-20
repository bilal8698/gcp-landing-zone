variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "name" {
  description = "Name prefix for the instance group and template"
  type        = string
}

variable "region" {
  description = "Region for the instance template"
  type        = string
}

variable "zone" {
  description = "Zone for the instance group"
  type        = string
}

variable "machine_type" {
  description = "Machine type for Palo Alto VMs"
  type        = string
  default     = "n2-standard-4"
}

variable "palo_alto_image" {
  description = "Palo Alto VM-Series image"
  type        = string
  default     = "https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/vmseries-flex-byol-1110"
}

variable "boot_disk_size_gb" {
  description = "Boot disk size in GB"
  type        = number
  default     = 60
}

variable "boot_disk_type" {
  description = "Boot disk type"
  type        = string
  default     = "pd-ssd"
}

variable "mgmt_subnet_self_link" {
  description = "Self link of the management subnet"
  type        = string
}

variable "data_subnet_self_link" {
  description = "Self link of the data plane subnet"
  type        = string
}

variable "mgmt_interface_has_external_ip" {
  description = "Whether management interface should have external IP"
  type        = bool
  default     = false
}

variable "data_interface_has_external_ip" {
  description = "Whether data interface should have external IP"
  type        = bool
  default     = false
}

variable "service_account_email" {
  description = "Service account email for the VMs"
  type        = string
}

variable "ssh_keys" {
  description = "SSH keys for VM access"
  type        = string
  default     = ""
}

variable "bootstrap_bucket_url" {
  description = "GCS bucket URL for bootstrap configuration"
  type        = string
  default     = ""
}

variable "metadata" {
  description = "Additional metadata for VMs"
  type        = map(string)
  default     = {}
}

variable "network_tags" {
  description = "Network tags for the VMs"
  type        = list(string)
  default     = []
}

variable "target_size" {
  description = "Number of instances in the group"
  type        = number
  default     = 2
}

variable "health_check_self_link" {
  description = "Self link of the health check for auto-healing"
  type        = string
}

variable "auto_healing_initial_delay_sec" {
  description = "Initial delay for auto-healing in seconds"
  type        = number
  default     = 600
}

variable "max_surge" {
  description = "Maximum number of instances to create during update"
  type        = number
  default     = 1
}

variable "max_unavailable" {
  description = "Maximum number of instances that can be unavailable during update"
  type        = number
  default     = 0
}

variable "enable_autoscaling" {
  description = "Enable autoscaling for the instance group"
  type        = bool
  default     = false
}

variable "autoscaling_min_replicas" {
  description = "Minimum number of replicas for autoscaling"
  type        = number
  default     = 2
}

variable "autoscaling_max_replicas" {
  description = "Maximum number of replicas for autoscaling"
  type        = number
  default     = 10
}

variable "autoscaling_cooldown_period" {
  description = "Cooldown period for autoscaling in seconds"
  type        = number
  default     = 300
}

variable "autoscaling_cpu_target" {
  description = "Target CPU utilization for autoscaling"
  type        = number
  default     = 0.7
}

variable "autoscaling_custom_metrics" {
  description = "Custom metrics for autoscaling"
  type = list(object({
    name   = string
    target = number
    type   = string
  }))
  default = []
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}
