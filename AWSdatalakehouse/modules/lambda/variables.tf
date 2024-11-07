variable "sharepoint_api_key" {
  description = "API key for Sharepoint"
  type        = string
}

variable "confluence_api_key" {
  description = "API key for Confluence"
  type        = string
}

# S3 Bucket for Lambda Code
variable "lambda_code_s3_bucket" {
  description = "The S3 bucket where the Lambda code is stored."
  type        = string
}

# S3 Key for Lambda Code
variable "lambda_code_s3_key" {
  description = "The S3 key (path) for the Lambda code .zip file."
  type        = string
}

# Environment (for tagging and resource management)
variable "environment" {
  description = "The environment in which the data lake is being deployed, e.g., dev, staging, production."
  type        = string
  default     = "dev"
}
