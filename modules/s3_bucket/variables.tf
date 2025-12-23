variable "name_prefix" {
  description = "Prefix for resource naming"
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket name. If null, a name will be auto-generated"
  type        = string
  default     = null
}

variable "lifecycle_expiration_days" {
  description = "Number of days until objects expire"
  type        = number
  default     = 1
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
