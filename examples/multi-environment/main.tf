# =============================================================================
# Multi-Environment Template
# =============================================================================
# Copy this file to each environment folder (dev/, staging/, prod/) and
# customize the terraform.tfvars for each environment.
# =============================================================================

terraform {
  required_version = ">= 1.2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }

  # Uncomment and configure for remote state
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "reducto-hybrid-infra/${var.environment}/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  # }
}

provider "aws" {
  region = var.aws_region
}

module "reducto_hybrid" {
  source = "../../../"

  name_prefix            = "${var.name_prefix}-${var.environment}"
  reducto_principal_arns = var.reducto_principal_arns
  reducto_external_id    = var.reducto_external_id

  # Optional: enable PrivateLink
  # enable_privatelink            = var.enable_privatelink
  # vpc_id                        = var.vpc_id
  # subnet_ids                    = var.subnet_ids
  # reducto_endpoint_service_name = var.reducto_endpoint_service_name

  tags = merge(
    var.tags,
    {
      Environment = var.environment
    }
  )
}

# =============================================================================
# Variables
# =============================================================================

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
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

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# =============================================================================
# Outputs
# =============================================================================

output "integration_values" {
  description = "Values to provide to Reducto for onboarding"
  value       = module.reducto_hybrid.integration_values
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}
