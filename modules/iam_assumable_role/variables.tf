variable "name_prefix" {
  description = "Prefix for resource naming"
  type        = string
}

variable "reducto_principal_arns" {
  description = "Reducto AWS principal ARNs that can assume this role"
  type        = list(string)
}

variable "reducto_external_id" {
  description = "ExternalId for secure role assumption (prevents confused deputy attacks)"
  type        = string
}

variable "bucket_arn" {
  description = "ARN of the S3 bucket to grant access to"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
