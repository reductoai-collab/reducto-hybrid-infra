# =============================================================================
# Bucket Policy Access for Reducto
# =============================================================================
# Alternative to IAM assume-role: grants Reducto principals direct access
# to the S3 bucket via bucket policy.
#
# NOTE: This is simpler but does not provide ExternalId protection against
# confused deputy attacks. The assume_role access mode is recommended.
# =============================================================================

resource "aws_s3_bucket_policy" "reducto_access" {
  bucket = var.bucket_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReductoListBucket"
        Effect = "Allow"
        Principal = {
          AWS = var.reducto_principal_arns
        }
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = var.bucket_arn
      },
      {
        Sid    = "ReductoObjectAccess"
        Effect = "Allow"
        Principal = {
          AWS = var.reducto_principal_arns
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${var.bucket_arn}/*"
      },
      {
        Sid    = "ReductoMultipartUpload"
        Effect = "Allow"
        Principal = {
          AWS = var.reducto_principal_arns
        }
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
