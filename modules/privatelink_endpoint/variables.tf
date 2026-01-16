variable "name_prefix" {
  description = "Prefix for resource naming"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the endpoint will be created"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the endpoint ENIs"
  type        = list(string)
}

variable "reducto_endpoint_service_name" {
  description = "Reducto VPC Endpoint Service name (provided by Reducto)"
  type        = string
}

variable "reducto_endpoint_service_region" {
  description = "Reducto VPC Endpoint Service region (provided by Reducto)"
  type        = string
}

variable "security_group_ids" {
  description = "Additional security group IDs to attach. If empty, a default security group will be created"
  type        = list(string)
  default     = []
}

variable "private_dns_enabled" {
  description = "Whether to enable private DNS for the endpoint"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
