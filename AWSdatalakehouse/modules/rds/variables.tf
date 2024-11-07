# Use the VPC ID passed from the root module
variable "vpc_id" {
  description = "The ID of the VPC where RDS should be deployed"
  type        = string
}

# Use the private subnet IDs passed from the root module
variable "private_subnet_ids" {
  description = "The IDs of the private subnets for RDS"
  type        = list(string)
}

# List of allowed security groups (e.g., for Lambda or EC2 instances in the same VPC)
variable "allowed_security_groups" {
  description = "List of security group IDs that are allowed to access RDS (e.g., Lambda or EC2 security groups)."
  type        = list(string)
  default     = []  # Fill this with security group IDs of Lambda or EC2 if applicable
}

# Allowed CIDRs for inbound access (e.g., Lambda, Glue, or EC2)
variable "allowed_cidrs" {
  description = "The list of allowed CIDRs to access the RDS instance."
  type        = list(string)
  default     = ["10.0.0.0/16"]  # Adjust based on your trusted sources
}

# RDS Engine (e.g., postgres or mysql)
variable "rds_engine" {
  description = "The database engine to use (e.g., postgres or mysql)."
  type        = string
  default     = "postgres"
}

# RDS Engine Version
variable "engine_version" {
  description = "The version of the database engine."
  type        = string
  default     = "12.4"
}

# RDS Instance Class
variable "instance_class" {
  description = "The instance class for RDS (e.g., db.t3.medium)."
  type        = string
  default     = "db.t3.medium"
}

# Database Name
variable "db_name" {
  description = "The name of the database to create in the RDS instance."
  type        = string
  default     = "mydatabase"
}

# Master Username
variable "db_username" {
  description = "The master username for the database."
  type        = string
  default     = "admin"
}

# Master Password
variable "db_password" {
  description = "The master password for the database."
  type        = string
  default     = "ChangeMe123!"  # Use sensitive management or Secrets Manager
}

# Storage Configuration
variable "allocated_storage" {
  description = "The allocated storage for the RDS instance (in GB)."
  type        = number
  default     = 20
}

variable "storage_type" {
  description = "The type of storage for the RDS instance (gp2, io1, etc.)."
  type        = string
  default     = "gp2"
}

# Multi-AZ Deployment
variable "multi_az" {
  description = "Enable Multi-AZ deployment for RDS."
  type        = bool
  default     = true
}

# Backup Retention Period
variable "backup_retention" {
  description = "Number of days to retain backups."
  type        = number
  default     = 7
}

# Encryption
variable "storage_encrypted" {
  description = "Enable storage encryption for the RDS instance."
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS Key ID for encryption (leave null to use default AWS key)."
  type        = string
  default     = null
}

# RDS Parameter Group Family
variable "rds_family" {
  description = "RDS Parameter group family (e.g., postgres12 or mysql5.7)."
  type        = string
  default     = "postgres12"
}

# Environment for tagging
variable "environment" {
  description = "The environment (e.g., dev, staging, prod) for tagging."
  type        = string
  default     = "dev"
}
