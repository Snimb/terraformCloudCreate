variable "name_prefix" {
  default     = "postgresqlfs" # Default prefix for resource names to ensure uniqueness.
  description = "Prefix of the resource name."
}

variable "location" {
  default     = "West Europe" # Default location for all resources.
  description = "Location of the resource - primary location."
}

# This file defines variables used throughout the Terraform configuration, providing default values and descriptions.

variable "subscription_id" {}

variable "tenant_id" {}