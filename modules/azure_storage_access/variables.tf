variable "name_prefix" {
  description = "Prefix for resource naming"
  type        = string
}

variable "storage_account_id" {
  description = "Azure Storage Account resource ID where Reducto will read/write data"
  type        = string
}

variable "container_names" {
  description = "List of container names within the storage account that Reducto should have access to. If empty, grants access to the entire storage account"
  type        = list(string)
  default     = []
}

variable "reducto_principal_id" {
  description = "Reducto Azure service principal object ID that will be granted access (provided by Reducto during onboarding)"
  type        = string
}

variable "role_definition_name" {
  description = "Azure built-in role to assign. Defaults to 'Storage Blob Data Contributor' which allows read/write/delete of blobs"
  type        = string
  default     = "Storage Blob Data Contributor"
}
