# S3 Bucket Name
variable "data_lake_bucket_name" {
  description = "The name of the S3 bucket for the data lake."
  type        = string
  default     = "my-data-lake-bucket"  # You can change this to customize the bucket name
}

# Logging Bucket Name (for audit logging)
variable "logging_bucket_name" {
  description = "The name of the S3 bucket where access logs will be stored."
  type        = string
  default     = "my-logging-bucket"
}

# Environment (for tagging and resource management)
variable "environment" {
  description = "The environment in which the data lake is being deployed, e.g., dev, staging, production."
  type        = string
  default     = "dev"
}

# Enable Server-Side Encryption (SSE) with KMS or AES256
variable "enable_sse_kms" {
  description = "Whether to use KMS-managed encryption keys for server-side encryption."
  type        = bool
  default     = false  # Set this to true if you want to use KMS instead of AES256
}

# Enable Logging
variable "enable_logging" {
  description = "Whether to enable logging for the S3 bucket."
  type        = bool
  default     = true
}

# Enable Versioning
variable "enable_versioning" {
  description = "Whether to enable versioning on the S3 bucket."
  type        = bool
  default     = true
}

# Transition Data to Glacier After X Days (for lifecycle management)
variable "lifecycle_transition_days" {
  description = "The number of days after which data in the raw folder will transition to Glacier storage."
  type        = number
  default     = 90  # You can modify this based on your data retention policy
}

# IAM Roles for Access (Glue, Lambda, etc.)
variable "iam_roles" {
  description = "List of IAM role ARNs that should have access to the S3 bucket."
  type        = list(string)
  default     = [
    "arn:aws:iam::123456789012:role/aws-glue-service-role",
    "arn:aws:iam::123456789012:role/lambda-execution-role"
  ]  # Replace these with your actual IAM roles
}
