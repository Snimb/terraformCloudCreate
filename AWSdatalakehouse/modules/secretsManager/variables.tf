variable "db_username" {
    type = string
}

variable "db_password" {
    type = string
}

# Environment (for tagging and resource management)
variable "environment" {
  description = "The environment in which the data lake is being deployed, e.g., dev, staging, production."
  type        = string
  default     = "dev"
}
