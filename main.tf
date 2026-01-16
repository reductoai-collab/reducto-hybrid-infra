# =============================================================================
# Reducto Hybrid VPC Infrastructure
# =============================================================================
# This module provisions the customer-side infrastructure required for
# Reducto Hybrid VPC deployment, including S3 storage, IAM access, and
# optional PrivateLink connectivity.
# =============================================================================

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# =============================================================================
# Local Variables
# =============================================================================

locals {
  # Merge default tags with user-provided tags
  tags = merge(
    {
      "ManagedBy" = "terraform"
      "Purpose"   = "reducto-hybrid-vpc"
    },
    var.tags
  )

  # Validate ExternalId is provided when using assume_role mode
  validate_external_id = var.access_mode == "assume_role" && var.reducto_external_id == null ? tobool("reducto_external_id is required when access_mode is 'assume_role'") : true

  # Validate PrivateLink configuration
  validate_privatelink_vpc     = var.enable_privatelink && var.vpc_id == null ? tobool("vpc_id is required when enable_privatelink is true") : true
  validate_privatelink_subnets = var.enable_privatelink && length(var.subnet_ids) == 0 ? tobool("subnet_ids is required when enable_privatelink is true") : true
  validate_privatelink_service = var.enable_privatelink && var.reducto_endpoint_service_name == null ? tobool("reducto_endpoint_service_name is required when enable_privatelink is true") : true
}

# =============================================================================
# S3 Bucket Module
# =============================================================================

module "s3_bucket" {
  source = "./modules/s3_bucket"

  name_prefix               = var.name_prefix
  bucket_name               = var.bucket_name
  lifecycle_expiration_days = var.lifecycle_expiration_days
  tags                      = local.tags
}

# =============================================================================
# IAM Assumable Role Module (when access_mode = "assume_role")
# =============================================================================

module "iam_assumable_role" {
  source = "./modules/iam_assumable_role"
  count  = var.access_mode == "assume_role" ? 1 : 0

  name_prefix            = var.name_prefix
  reducto_principal_arns = var.reducto_principal_arns
  reducto_external_id    = var.reducto_external_id
  bucket_arn             = module.s3_bucket.bucket_arn
  bucket_name            = module.s3_bucket.bucket_name
  tags                   = local.tags
}

# =============================================================================
# Bucket Policy Access Module (when access_mode = "bucket_policy")
# =============================================================================

module "bucket_policy_access" {
  source = "./modules/bucket_policy_access"
  count  = var.access_mode == "bucket_policy" ? 1 : 0

  bucket_name            = module.s3_bucket.bucket_name
  bucket_arn             = module.s3_bucket.bucket_arn
  reducto_principal_arns = var.reducto_principal_arns
}

# =============================================================================
# PrivateLink Endpoint Module (optional)
# =============================================================================

module "privatelink_endpoint" {
  source = "./modules/privatelink_endpoint"
  count  = var.enable_privatelink ? 1 : 0

  name_prefix                     = var.name_prefix
  vpc_id                          = var.vpc_id
  subnet_ids                      = var.subnet_ids
  reducto_endpoint_service_name   = var.reducto_endpoint_service_name
  reducto_endpoint_service_region = var.reducto_endpoint_service_region
  security_group_ids              = var.privatelink_security_group_ids
  tags                            = local.tags
}
