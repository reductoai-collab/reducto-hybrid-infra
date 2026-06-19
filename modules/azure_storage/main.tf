# =============================================================================
# Azure Storage Account for Reducto Hybrid VPC
# =============================================================================
# Creates an Azure Storage Account with:
# - Automatic blob expiration (default: 24 hours)
# - Encryption enabled (Azure default)
# - Public access blocked
# - Blob container for Reducto data
# =============================================================================

resource "random_id" "storage_suffix" {
  count       = var.storage_account_name == null ? 1 : 0
  byte_length = 4
}

locals {
  # Storage account names: 3-24 chars, lowercase alphanumeric only (no hyphens)
  # Remove hyphens from prefix and combine with suffix
  sanitized_prefix     = replace(lower(var.name_prefix), "-", "")
  storage_account_name = var.storage_account_name != null ? var.storage_account_name : "${local.sanitized_prefix}reducto${random_id.storage_suffix[0].hex}"
}

# -----------------------------------------------------------------------------
# Storage Account
# -----------------------------------------------------------------------------

resource "azurerm_storage_account" "this" {
  name                = local.storage_account_name
  resource_group_name = var.resource_group_name
  location            = var.location

  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type

  # Security settings
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = true
  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true

  # Blob settings
  blob_properties {
    versioning_enabled = false

    delete_retention_policy {
      days = 1
    }

    container_delete_retention_policy {
      days = 1
    }
  }

  tags = merge(
    var.tags,
    {
      Name = local.storage_account_name
    }
  )
}

# -----------------------------------------------------------------------------
# Blob Container
# -----------------------------------------------------------------------------

resource "azurerm_storage_container" "this" {
  name                  = var.container_name
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
}

# -----------------------------------------------------------------------------
# Lifecycle Management - Auto-expire blobs
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
        delete_after_days_since_creation_greater_than = var.lifecycle_expiration_days
      }
    }
  }
}
