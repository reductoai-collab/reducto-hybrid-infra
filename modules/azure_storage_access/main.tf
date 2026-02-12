# =============================================================================
# Azure Storage Access for Reducto
# =============================================================================
# Creates role assignments that allow Reducto's Azure service principal to
# access the customer's Azure Storage Account. This enables cross-tenant
# access where Reducto's AWS infrastructure (using Azure credentials) can
# read/write to the customer's Azure Blob Storage.
# =============================================================================

locals {
  # When container_names is empty, grant access at storage account level
  # When container_names is provided, grant access at container level for least-privilege
  grant_at_account_level = length(var.container_names) == 0

  # Build container scope IDs when specific containers are specified
  container_scopes = {
    for name in var.container_names :
    name => "${var.storage_account_id}/blobServices/default/containers/${name}"
  }
}

# -----------------------------------------------------------------------------
# Role Assignment at Storage Account Level
# Used when no specific containers are specified
# -----------------------------------------------------------------------------

resource "azurerm_role_assignment" "storage_account" {
  count = local.grant_at_account_level ? 1 : 0

  scope                = var.storage_account_id
  role_definition_name = var.role_definition_name
  principal_id         = var.reducto_principal_id
  principal_type       = "ServicePrincipal"

  description = "Grants Reducto access to Azure Storage for hybrid VPC integration"
}

# -----------------------------------------------------------------------------
# Role Assignments at Container Level
# Used when specific containers are specified (recommended for least-privilege)
# -----------------------------------------------------------------------------

resource "azurerm_role_assignment" "container" {
  for_each = local.grant_at_account_level ? {} : local.container_scopes

  scope                = each.value
  role_definition_name = var.role_definition_name
  principal_id         = var.reducto_principal_id
  principal_type       = "ServicePrincipal"

  description = "Grants Reducto access to container '${each.key}' for hybrid VPC integration"
}
