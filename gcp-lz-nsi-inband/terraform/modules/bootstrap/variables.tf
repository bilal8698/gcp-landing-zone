variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "bucket_name" {
  description = "Name of the GCS bucket for bootstrap files"
  type        = string
}

variable "location" {
  description = "Location for the GCS bucket"
  type        = string
  default     = "US"
}

variable "force_destroy" {
  description = "Allow bucket to be destroyed even if it contains objects"
  type        = bool
  default     = false
}

variable "lifecycle_age_days" {
  description = "Number of days before objects are deleted"
  type        = number
  default     = 365
}

variable "service_account_email" {
  description = "Service account email for VMs to access bootstrap bucket"
  type        = string
}

variable "hostname" {
  description = "Firewall hostname"
  type        = string
  default     = "paloalto-fw"
}

variable "panorama_server" {
  description = "Primary Panorama server IP or FQDN"
  type        = string
  default     = ""
}

variable "panorama_server2" {
  description = "Secondary Panorama server IP or FQDN"
  type        = string
  default     = ""
}

variable "template_name" {
  description = "Panorama template name"
  type        = string
  default     = ""
}

variable "device_group_name" {
  description = "Panorama device group name"
  type        = string
  default     = ""
}

variable "vm_auth_key" {
  description = "VM auth key for Panorama"
  type        = string
  default     = ""
  sensitive   = true
}

variable "op_command_modes" {
  description = "Operation command modes"
  type        = string
  default     = "mgmt-interface-swap"
}

variable "dns_primary" {
  description = "Primary DNS server"
  type        = string
  default     = "8.8.8.8"
}

variable "dns_secondary" {
  description = "Secondary DNS server"
  type        = string
  default     = "8.8.4.4"
}

variable "ntp_primary" {
  description = "Primary NTP server"
  type        = string
  default     = "time.google.com"
}

variable "ntp_secondary" {
  description = "Secondary NTP server"
  type        = string
  default     = "time.cloudflare.com"
}

variable "timezone" {
  description = "Timezone"
  type        = string
  default     = "US/Eastern"
}

variable "login_banner" {
  description = "Login banner text"
  type        = string
  default     = "Authorized Access Only"
}

variable "vm_series_auto_registration" {
  description = "Enable VM-Series auto-registration"
  type        = string
  default     = "yes"
}

variable "bootstrap_xml_template" {
  description = "Path to bootstrap.xml template file"
  type        = string
  default     = ""
}

variable "bootstrap_xml_vars" {
  description = "Variables for bootstrap.xml template"
  type        = map(any)
  default     = {}
}

variable "authcodes" {
  description = "Map of license authcodes"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "content_files" {
  description = "Map of content files to upload (key: destination name, value: source path)"
  type        = map(string)
  default     = {}
}

variable "software_files" {
  description = "Map of software files to upload (key: destination name, value: source path)"
  type        = map(string)
  default     = {}
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}
