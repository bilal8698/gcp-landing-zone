variable "project_id" {
  description = "The GCP project ID for the producer service"
  type        = string
}

variable "name" {
  description = "Name of the intercept deployment group"
  type        = string
}

variable "location" {
  description = "Region where the intercept deployment group is created"
  type        = string
}

variable "description" {
  description = "Description of the intercept deployment group"
  type        = string
  default     = "In-band packet inspection deployment group"
}

variable "labels" {
  description = "Labels to apply to the intercept deployment group"
  type        = map(string)
  default     = {}
}

variable "external_user_principals" {
  description = "List of IAM principals (service accounts, users) who can use this deployment group"
  type        = list(string)
  default     = []
}
