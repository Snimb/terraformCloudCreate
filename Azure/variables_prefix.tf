variable "name_prefix" {
  default     = "azure" # Default prefix for resource names to ensure uniqueness.
  description = "Prefix of the resource name."
}

variable "vnet_prefix" {
  type        = string
  default     = "vnet"
  description = "Prefix of the vnet name."
}

variable "subnet_prefix" {
  type        = string
  default     = "snet"
  description = "Prefix of the Subnet name."
}

variable "nsg_prefix" {
  type        = string
  default     = "nsg"
  description = "Prefix of the network security group name."
}

variable "pdz_prefix" {
  type        = string
  default     = "nsg"
  description = "Prefix of the private DNS zone name."
}

variable "log_analytics_workspace_prefix" {
  type        = string
  default     = "workspace"
  description = "Prefix of the log analytics workspace prefix resource."
}

variable "kv_prefix" {
  type        = string
  default     = "kv"
  description = "Prefix of the Azure key vault."
}

variable "private_endpoint_prefix" {
  type        = string
  default     = "pe"
  description = "Prefix of the private endpoint."
}

variable "diag_prefix" {
  type        = string
  default     = "diag"
  description = "Prefix of the Diagnostic Settings resource."
}
