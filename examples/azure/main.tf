# Azure Blob Storage — Hybrid VPC Example
#
# Provisions an Azure Storage Account and Blob Container for Reducto Hybrid VPC,
# with cross-tenant RBAC access for Reducto's service principal.
#
# Usage:
#   1. Copy this file and create terraform.tfvars with your values
#   2. terraform init && terraform apply
#   3. Share the outputs with Reducto

terraform {
  required_version = ">= 1.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# -----------------------------------------------------------------------------
# Variables
# -----------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for all resource names"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.name_prefix))
    error_message = "name_prefix must contain only lowercase letters, numbers, and hyphens"
  }
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Name of the resource group (created if it doesn't exist)"
  type        = string
  default     = ""
}

variable "reducto_service_principal_object_id" {
  description = "Object ID of Reducto's service principal in your Azure AD tenant (provided by Reducto during onboarding)"
  type        = string
}

variable "lifecycle_expiration_days" {
  description = "Number of days after which blobs are automatically deleted"
  type        = number
  default     = 1

  validation {
    condition     = var.lifecycle_expiration_days >= 1
    error_message = "lifecycle_expiration_days must be at least 1"
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Locals
# -----------------------------------------------------------------------------

locals {
  resource_group_name = var.resource_group_name != "" ? var.resource_group_name : "${var.name_prefix}-reducto-rg"
  # Storage account names must be 3-24 chars, lowercase alphanumeric only
  storage_account_name = replace("${var.name_prefix}reducto", "-", "")

  common_tags = merge(var.tags, {
    ManagedBy = "terraform"
    Purpose   = "reducto-hybrid-vpc"
  })
}

# -----------------------------------------------------------------------------
# Resource Group
# -----------------------------------------------------------------------------

resource "azurerm_resource_group" "this" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.common_tags
}

# -----------------------------------------------------------------------------
# Storage Account
# -----------------------------------------------------------------------------

resource "azurerm_storage_account" "this" {
  name                     = substr(local.storage_account_name, 0, 24)
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Security settings
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  cross_tenant_replication_enabled = false

  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Blob Container
# -----------------------------------------------------------------------------

resource "azurerm_storage_container" "this" {
  name                  = "reducto-documents"
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
}

# -----------------------------------------------------------------------------
# Lifecycle Management
# -----------------------------------------------------------------------------

resource "azurerm_storage_management_policy" "this" {
  storage_account_id = azurerm_storage_account.this.id

  rule {
    name    = "reducto-auto-expire"
    enabled = true

    filters {
      blob_types = ["blockBlob"]
    }

    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = var.lifecycle_expiration_days
      }
    }
  }
}

# -----------------------------------------------------------------------------
# RBAC — Grant Reducto's service principal access
# -----------------------------------------------------------------------------

resource "azurerm_role_assignment" "reducto_blob_contributor" {
  scope                            = azurerm_storage_account.this.id
  role_definition_name             = "Storage Blob Data Contributor"
  principal_id                     = var.reducto_service_principal_object_id
  skip_service_principal_aad_check = true
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "integration_values" {
  description = "Values to provide to Reducto for onboarding"
  value = {
    storage_account_name = azurerm_storage_account.this.name
    container_name       = azurerm_storage_container.this.name
    location             = azurerm_resource_group.this.location
  }
}

output "storage_account_name" {
  description = "Name of the Storage Account"
  value       = azurerm_storage_account.this.name
}

output "container_name" {
  description = "Name of the Blob Container"
  value       = azurerm_storage_container.this.name
}

output "connection_string" {
  description = "Storage Account connection string (share securely with Reducto)"
  value       = azurerm_storage_account.this.primary_connection_string
  sensitive   = true
}
