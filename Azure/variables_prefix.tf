variable "rg_prefix" {
  type        = string
  default     = "rg"
  description = "Prefix of the resource group name that's combined with name of the resource group."
}

variable "name_prefix" {
  default     = "postgresqlfs" # Default prefix for resource names to ensure uniqueness.
  description = "Prefix of the resource name."
}

resource "random_pet" "name_prefix" {
  prefix = var.name_prefix # Generates a random name prefix to ensure resource names are unique.
  length = 1               # Specifies the number of words in the generated name.
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

variable "hub_gateway_subnet_address_prefixes" {
  description = "Specifies the address prefix of the hub gateway subnet"
  type        = list(string)
}
