# =============================================================================
# PrivateLink Endpoint for Reducto
# =============================================================================
# Creates a VPC Interface Endpoint to connect to Reducto's API privately
# without traversing the public internet.
# =============================================================================

data "aws_vpc" "selected" {
  id = var.vpc_id
}

locals {
  # Use provided security groups or create a default one
  create_security_group = length(var.security_group_ids) == 0
  security_group_ids    = local.create_security_group ? [aws_security_group.endpoint[0].id] : var.security_group_ids
}

# -----------------------------------------------------------------------------
# Security Group (created if none provided)
# -----------------------------------------------------------------------------

resource "aws_security_group" "endpoint" {
  count = local.create_security_group ? 1 : 0

  name        = "${var.name_prefix}-reducto-privatelink"
  description = "Security group for Reducto PrivateLink endpoint"
  vpc_id      = var.vpc_id

  # Allow HTTPS inbound from VPC CIDR
  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  # Allow all outbound (for responses)
  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-reducto-privatelink"
    }
  )
}

# -----------------------------------------------------------------------------
# VPC Endpoint (Interface type for PrivateLink)
# -----------------------------------------------------------------------------

resource "aws_vpc_endpoint" "reducto" {
  vpc_id            = var.vpc_id
  service_name      = var.reducto_endpoint_service_name
  service_region    = var.reducto_endpoint_service_region
  vpc_endpoint_type = "Interface"

  subnet_ids          = var.subnet_ids
  security_group_ids  = local.security_group_ids
  private_dns_enabled = var.private_dns_enabled

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-reducto-privatelink"
    }
  )
}
