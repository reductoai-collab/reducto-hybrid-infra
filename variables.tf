# =============================================================================
# Required Variables
# =============================================================================

variable "name_prefix" {
  description = "Prefix for resource naming (e.g., 'reducto', 'reducto-prod')"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.name_prefix))
    error_message = "name_prefix must contain only lowercase letters, numbers, and hyphens"
  }
}

variable "reducto_principal_arns" {
  description = "Reducto AWS principal ARNs that will be granted access (provided by Reducto during onboarding)"
  type        = list(string)

  validation {
    condition     = length(var.reducto_principal_arns) > 0
    error_message = "At least one Reducto principal ARN must be provided"
  }
}

# =============================================================================
# S3 Configuration
# =============================================================================

variable "bucket_name" {
  description = "S3 bucket name. If not specified, a name will be auto-generated using name_prefix"
  type        = string
  default     = null
}

variable "lifecycle_expiration_days" {
  description = "Number of days until objects in the bucket expire and are automatically deleted"
  type        = number
  default     = 1

  validation {
    condition     = var.lifecycle_expiration_days >= 1
    error_message = "lifecycle_expiration_days must be at least 1"
  }
}

# =============================================================================
# IAM Access Mode
# =============================================================================

variable "access_mode" {
  description = "How Reducto accesses S3: 'assume_role' (recommended, uses ExternalId for security) or 'bucket_policy' (simpler, direct access)"
  type        = string
  default     = "assume_role"

  validation {
    condition     = contains(["assume_role", "bucket_policy"], var.access_mode)
    error_message = "access_mode must be 'assume_role' or 'bucket_policy'"
  }
}

variable "reducto_external_id" {
  description = "ExternalId for IAM role assumption (required if access_mode = 'assume_role'). Provided by Reducto during onboarding"
  type        = string
  default     = null
}

# =============================================================================
# PrivateLink Configuration (Optional)
# =============================================================================

variable "enable_privatelink" {
  description = "Enable AWS PrivateLink endpoint for private-only API access to Reducto"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "VPC ID where the PrivateLink endpoint will be created (required if enable_privatelink = true)"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "Subnet IDs for the PrivateLink endpoint ENIs (required if enable_privatelink = true)"
  type        = list(string)
  default     = []
}

variable "reducto_endpoint_service_name" {
  description = "Reducto VPC Endpoint Service name (provided by Reducto). Required if enable_privatelink = true"
  type        = string
  default     = null
}

variable "reducto_endpoint_service_region" {
  description = "Reducto VPC Endpoint Service region (provided by Reducto). Required if enable_privatelink = true"
  type        = string
  default     = null
}

variable "privatelink_security_group_ids" {
  description = "Additional security group IDs to attach to the PrivateLink endpoint. If not specified, a default security group allowing HTTPS will be created"
  type        = list(string)
  default     = []
}

# =============================================================================
# Azure Storage Configuration (Optional)
# =============================================================================

variable "enable_azure_storage" {
  description = "Enable Azure Storage for Reducto (creates storage account and container, grants Reducto access)"
  type        = bool
  default     = false
}

variable "azure_resource_group_name" {
  description = "Name of the Azure resource group where storage resources will be created (required if enable_azure_storage = true)"
  type        = string
  default     = null
}

variable "azure_location" {
  description = "Azure region where storage resources will be created (required if enable_azure_storage = true)"
  type        = string
  default     = null
}

variable "azure_storage_account_name" {
  description = "Azure Storage Account name. If not specified, a name will be auto-generated. Must be 3-24 chars, lowercase alphanumeric only"
  type        = string
  default     = null
}

variable "azure_container_name" {
  description = "Name of the blob container to create for Reducto"
  type        = string
  default     = "reducto"
}

variable "azure_lifecycle_expiration_days" {
  description = "Number of days until blobs expire and are automatically deleted"
  type        = number
  default     = 1

  validation {
    condition     = var.azure_lifecycle_expiration_days >= 1
    error_message = "azure_lifecycle_expiration_days must be at least 1"
  }
}

variable "reducto_azure_principal_id" {
  description = "Reducto Azure service principal object ID (required if enable_azure_storage = true). Provided by Reducto during onboarding"
  type        = string
  default     = null
}

variable "azure_role_definition_name" {
  description = "Azure built-in role to assign. Defaults to 'Storage Blob Data Contributor' which allows read/write/delete of blobs"
  type        = string
  default     = "Storage Blob Data Contributor"
}

# =============================================================================
# Tags
# =============================================================================

variable "tags" {
  description = "Tags to apply to all resources created by this module"
  type        = map(string)
  default     = {}
}
