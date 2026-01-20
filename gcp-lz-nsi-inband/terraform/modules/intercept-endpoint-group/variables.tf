variable "project_id" {
  description = "The GCP project ID for the consumer service"
  type        = string
}

variable "name" {
  description = "Name of the intercept endpoint group"
  type        = string
}

variable "location" {
  description = "Region where the endpoint group is created"
  type        = string
}

variable "description" {
  description = "Description of the intercept endpoint group"
  type        = string
  default     = "Consumer intercept endpoint group for in-band inspection"
}

variable "producer_deployment_group_name" {
  description = "Full resource name of the producer's intercept deployment group"
  type        = string
}

variable "vpc_network_names" {
  description = "List of VPC network names to associate with this endpoint group"
  type        = list(string)
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}
