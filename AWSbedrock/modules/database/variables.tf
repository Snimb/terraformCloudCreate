variable "db_username" {
  default = "admin"
}

variable "db_password" {
  default = "SuperSecretPassword"  # Store securely in production, e.g., using Secrets Manager
}

variable "db_instance_class" {
  default = "db.t3.medium"  # Choose instance type based on your load requirements
}

variable "db_allocated_storage" {
  default = 20  # Storage size in GB
}

variable "vpc_id" {
  description = "The ID of the VPC where the RDS instance will be deployed"
}

variable "private_subnets" {
  description = "List of private subnet IDs across multiple Availability Zones for the RDS subnet group"
  type        = list(string)
}