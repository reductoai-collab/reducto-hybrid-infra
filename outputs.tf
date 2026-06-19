# =============================================================================
# S3 Bucket Outputs
# =============================================================================

output "bucket_name" {
  description = "S3 bucket name - provide this to Reducto"
  value       = module.s3_bucket.bucket_name
}

output "bucket_arn" {
  description = "S3 bucket ARN"
  value       = module.s3_bucket.bucket_arn
}

output "bucket_region" {
  description = "AWS region where the S3 bucket is located"
  value       = data.aws_region.current.id
}

# =============================================================================
# IAM Role Outputs
# =============================================================================

output "assumable_role_arn" {
  description = "IAM role ARN for Reducto to assume - provide this to Reducto (only set when access_mode = 'assume_role')"
  value       = var.access_mode == "assume_role" ? module.iam_assumable_role[0].role_arn : null
}

output "assumable_role_name" {
  description = "IAM role name (only set when access_mode = 'assume_role')"
  value       = var.access_mode == "assume_role" ? module.iam_assumable_role[0].role_name : null
}

# =============================================================================
# PrivateLink Outputs
# =============================================================================

output "privatelink_endpoint_id" {
  description = "VPC Endpoint ID - provide this to Reducto if using PrivateLink"
  value       = var.enable_privatelink ? module.privatelink_endpoint[0].endpoint_id : null
}

output "privatelink_dns_entries" {
  description = "DNS entries for the PrivateLink endpoint"
  value       = var.enable_privatelink ? module.privatelink_endpoint[0].dns_entries : null
}

# =============================================================================
# Azure Storage Outputs
# =============================================================================

output "azure_storage_account_name" {
  description = "Azure Storage Account name - provide this to Reducto (only set when enable_azure_storage = true)"
  value       = var.enable_azure_storage ? module.azure_storage[0].storage_account_name : null
}

output "azure_storage_account_id" {
  description = "Azure Storage Account resource ID (only set when enable_azure_storage = true)"
  value       = var.enable_azure_storage ? module.azure_storage[0].storage_account_id : null
}

output "azure_container_name" {
  description = "Azure Blob container name (only set when enable_azure_storage = true)"
  value       = var.enable_azure_storage ? module.azure_storage[0].container_name : null
}

output "azure_blob_endpoint" {
  description = "Azure primary blob service endpoint URL (only set when enable_azure_storage = true)"
  value       = var.enable_azure_storage ? module.azure_storage[0].primary_blob_endpoint : null
}

output "azure_role_assignment_ids" {
  description = "IDs of the Azure role assignments created for Reducto access (only set when enable_azure_storage = true)"
  value       = var.enable_azure_storage ? module.azure_storage_access[0].role_assignment_ids : null
}

# =============================================================================
# Integration Values (all-in-one output for Reducto onboarding)
# =============================================================================

output "integration_values" {
  description = "All values to provide to Reducto for onboarding. Share this output with your Reducto account team."
  value = {
    # AWS S3 Configuration
    bucket_name             = module.s3_bucket.bucket_name
    region                  = data.aws_region.current.id
    account_id              = data.aws_caller_identity.current.account_id
    access_mode             = var.access_mode
    role_arn                = var.access_mode == "assume_role" ? module.iam_assumable_role[0].role_arn : null
    privatelink_endpoint_id = var.enable_privatelink ? module.privatelink_endpoint[0].endpoint_id : null

    # Azure Storage Configuration
    azure_storage_enabled      = var.enable_azure_storage
    azure_storage_account_name = var.enable_azure_storage ? module.azure_storage[0].storage_account_name : null
    azure_container_name       = var.enable_azure_storage ? module.azure_storage[0].container_name : null
    azure_blob_endpoint        = var.enable_azure_storage ? module.azure_storage[0].primary_blob_endpoint : null
    azure_location             = var.enable_azure_storage ? var.azure_location : null
  }
}
