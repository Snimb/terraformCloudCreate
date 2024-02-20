variable "rg_prefix" {
  type        = string
  default     = "rg"
  description = "Prefix of the resource group name that's combined with name of the resource group."
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