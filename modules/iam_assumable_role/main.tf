# =============================================================================
# IAM Assumable Role for Reducto
# =============================================================================
# Creates an IAM role that Reducto can assume to access the S3 bucket.
# Uses ExternalId to prevent confused deputy attacks.
# =============================================================================

data "aws_caller_identity" "current" {}

locals {
  role_name = "${var.name_prefix}-reducto-access"
}

# -----------------------------------------------------------------------------
# IAM Role with Trust Policy
# -----------------------------------------------------------------------------

resource "aws_iam_role" "this" {
  name = local.role_name
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = var.reducto_principal_arns
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.reducto_external_id
          }
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = local.role_name
    }
  )
}

# -----------------------------------------------------------------------------
# IAM Policy for S3 Access
# -----------------------------------------------------------------------------

resource "aws_iam_role_policy" "s3_access" {
  name = "${var.name_prefix}-reducto-s3-access"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3BucketAccess"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = var.bucket_arn
      },
      {
        Sid    = "S3ObjectAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${var.bucket_arn}/*"
      },
      {
        Sid    = "S3MultipartUpload"
        Effect = "Allow"
        Action = [
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts",
          "s3:ListBucketMultipartUploads"
        ]
        Resource = [
          var.bucket_arn,
          "${var.bucket_arn}/*"
        ]
      }
    ]
  })
}
