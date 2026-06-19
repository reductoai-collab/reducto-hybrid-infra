variable "name_prefix" {
  description = "Prefix for resource naming"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Azure resource group where resources will be created"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "storage_account_name" {
  description = "Storage account name. If null, a name will be auto-generated. Must be 3-24 chars, lowercase alphanumeric only"
  type        = string
  default     = null
}

variable "container_name" {
  description = "Name of the blob container to create"
  type        = string
  default     = "reducto"
}

variable "lifecycle_expiration_days" {
  description = "Number of days until blobs expire and are automatically deleted"
  type        = number
  default     = 1
}

variable "account_tier" {
  description = "Storage account tier (Standard or Premium)"
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "Storage account replication type (LRS, GRS, RAGRS, ZRS)"
  type        = string
  default     = "LRS"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
