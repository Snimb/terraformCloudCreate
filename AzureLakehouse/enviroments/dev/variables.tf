# variable for location
variable "location" {
  description = "Location of the resource - primary location."
  type        = string
}

variable "vnet_address_space" {
  description = "Specifies the address space of the virtual virtual network"
  type        = list(string)
}

variable "private_subnet_address_prefix" {
  description = "Specifies the address space of the virtual virtual network"
  type        = list(string)
}

variable "public_subnet_address_prefix" {
  description = "Specifies the address space of the virtual virtual network"
  type        = list(string)
}

variable "databricks_ws_sku" {
  description = "SKU of the databricks workspace"
  type        = string
}