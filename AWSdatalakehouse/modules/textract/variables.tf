# Environment (for tagging and resource management)
variable "environment" {
  description = "The environment in which the data lake is being deployed, e.g., dev, staging, production."
  type        = string
  default     = "dev"
}

variable "lambda_code_s3_bucket" {
  type = string
}

variable "lambda_code_s3_key" {
  type = string
}