variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "bucket_arn" {
  description = "ARN of the S3 bucket"
  type        = string
}

variable "reducto_principal_arns" {
  description = "Reducto AWS principal ARNs that will be granted direct bucket access"
  type        = list(string)
}
