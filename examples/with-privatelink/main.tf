# =============================================================================
# Reducto Hybrid VPC with PrivateLink
# =============================================================================
# This example includes PrivateLink for private-only API access.
# =============================================================================

terraform {
  required_version = ">= 1.2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "reducto_hybrid" {
  source = "../../"

  name_prefix            = var.name_prefix
  reducto_principal_arns = var.reducto_principal_arns
  reducto_external_id    = var.reducto_external_id

  # PrivateLink configuration
  enable_privatelink            = true
  vpc_id                        = var.vpc_id
  subnet_ids                    = var.subnet_ids
  reducto_endpoint_service_name = var.reducto_endpoint_service_name

  tags = var.tags
}

# =============================================================================
# Variables
# =============================================================================

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix for resource naming"
  type        = string
  default     = "reducto"
}

variable "reducto_principal_arns" {
  description = "Reducto AWS principal ARNs (provided by Reducto)"
  type        = list(string)
}

variable "reducto_external_id" {
  description = "ExternalId for role assumption (provided by Reducto)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for PrivateLink endpoint"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for PrivateLink endpoint"
  type        = list(string)
}

variable "reducto_endpoint_service_name" {
  description = "Reducto VPC Endpoint Service name (provided by Reducto)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

# =============================================================================
# Outputs
# =============================================================================

output "integration_values" {
  description = "Values to provide to Reducto for onboarding"
  value       = module.reducto_hybrid.integration_values
}

output "bucket_name" {
  description = "S3 bucket name"
  value       = module.reducto_hybrid.bucket_name
}

output "role_arn" {
  description = "IAM role ARN for Reducto"
  value       = module.reducto_hybrid.assumable_role_arn
}

output "privatelink_endpoint_id" {
  description = "PrivateLink endpoint ID"
  value       = module.reducto_hybrid.privatelink_endpoint_id
}

output "privatelink_dns_entries" {
  description = "PrivateLink DNS entries"
  value       = module.reducto_hybrid.privatelink_dns_entries
}
