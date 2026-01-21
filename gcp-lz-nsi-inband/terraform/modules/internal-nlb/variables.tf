variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "name" {
  description = "Name of the internal NLB"
  type        = string
}

variable "region" {
  description = "Region for the load balancer"
  type        = string
}

variable "network_self_link" {
  description = "Self link of the VPC network"
  type        = string
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "subnetwork_self_link" {
  description = "Self link of the subnet"
  type        = string
}

variable "backend_protocol" {
  description = "Protocol for the backend service (UDP or UNSPECIFIED)"
  type        = string
  default     = "UDP"
  validation {
    condition     = contains(["UDP", "UNSPECIFIED"], var.backend_protocol)
    error_message = "Backend protocol must be UDP or UNSPECIFIED for NSI"
  }
}

variable "instance_groups" {
  description = "List of instance group objects with self_link property"
  type = list(object({
    self_link = string
  }))
}

variable "health_check_self_link" {
  description = "Self link of an existing health check resource"
  type        = string
}

variable "connection_draining_timeout_sec" {
  description = "Connection draining timeout in seconds"
  type        = number
  default     = 300
}

variable "session_affinity" {
  description = "Session affinity type (NONE, CLIENT_IP, CLIENT_IP_PROTO)"
  type        = string
  default     = "NONE"
}

variable "enable_failover" {
  description = "Enable failover configuration for high availability"
  type        = bool
  default     = true
}

variable "allow_global_access" {
  description = "Allow global access for cross-region traffic"
  type        = bool
  default     = false
}

variable "consumer_subnet_gateway_ips" {
  description = "List of consumer subnet gateway IP addresses to allow GENEVE traffic"
  type        = list(string)
}

variable "target_tags" {
  description = "Network tags for firewall rules targeting inspection VMs"
  type        = list(string)
  default     = ["packet-inspection"]
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}
