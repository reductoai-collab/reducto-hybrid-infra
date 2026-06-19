output "role_assignment_ids" {
  description = "IDs of the role assignments created for Reducto access"
  value = length(var.container_names) == 0 ? [azurerm_role_assignment.storage_account[0].id] : [
    for assignment in azurerm_role_assignment.container : assignment.id
  ]
}

output "role_assignment_scopes" {
  description = "Scopes where Reducto has been granted access"
  value = length(var.container_names) == 0 ? [var.storage_account_id] : [
    for name, scope in local.container_scopes : scope
  ]
}

output "principal_id" {
  description = "The Reducto service principal ID that was granted access"
  value       = var.reducto_principal_id
}

output "role_definition_name" {
  description = "The role that was assigned to Reducto"
  value       = var.role_definition_name
}
