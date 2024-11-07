# Environment (for tagging and resource management)
variable "environment" {
  description = "The environment in which the data lake is being deployed, e.g., dev, staging, production."
  type        = string
  default     = "dev"
}

variable "node_type" {
  type    = string
  default = "dc2.large"
}

variable "number_of_nodes" {
  type    = number
  default = 2
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
