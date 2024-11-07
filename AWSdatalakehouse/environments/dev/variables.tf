variable "location" {
  description = "Location of the setup"
  type        = string
}

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

variable "db_username" {
    type = string
}

variable "db_password" {
    type = string
}

variable "database_name" {
  type = string
}

variable "master_username" {
  type = string
}

variable "master_password" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_security_group_id" {
  type = string
}

variable "data_lake_bucket_name" {
  type = string
}