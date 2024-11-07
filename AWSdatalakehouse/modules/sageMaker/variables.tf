# Environment (for tagging and resource management)
variable "environment" {
  description = "The environment in which the data lake is being deployed, e.g., dev, staging, production."
  type        = string
  default     = "dev"
}

variable "instance_type" {
  type    = string
  default = "ml.t2.medium"
}
