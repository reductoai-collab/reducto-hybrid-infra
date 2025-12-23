# =============================================================================
# S3 Bucket for Reducto Hybrid VPC
# =============================================================================
# Creates an S3 bucket with:
# - Automatic object expiration (default: 24 hours)
# - Server-side encryption (SSE-S3)
# - Public access blocked
# - Bucket owner enforced ownership
# =============================================================================

resource "random_id" "bucket_suffix" {
  count       = var.bucket_name == null ? 1 : 0
  byte_length = 4
}

locals {
  bucket_name = var.bucket_name != null ? var.bucket_name : "${var.name_prefix}-reducto-${random_id.bucket_suffix[0].hex}"
}

# -----------------------------------------------------------------------------
# S3 Bucket
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "this" {
  bucket = local.bucket_name

  tags = merge(
    var.tags,
    {
      Name = local.bucket_name
    }
  )
}

# -----------------------------------------------------------------------------
# Lifecycle Configuration - Auto-expire objects
# -----------------------------------------------------------------------------

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "reducto-auto-expire"
    status = "Enabled"

    expiration {
      days = var.lifecycle_expiration_days
    }

    # Also clean up incomplete multipart uploads
    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }

    # Apply to all objects
    filter {}
  }
}

# -----------------------------------------------------------------------------
# Block Public Access
# -----------------------------------------------------------------------------

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -----------------------------------------------------------------------------
# Bucket Ownership Controls - Bucket owner enforced
# -----------------------------------------------------------------------------

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# -----------------------------------------------------------------------------
# Server-Side Encryption - SSE-S3 default
# -----------------------------------------------------------------------------

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# -----------------------------------------------------------------------------
# Versioning - Disabled (stateless design, objects are ephemeral)
# -----------------------------------------------------------------------------

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Disabled"
  }
}
