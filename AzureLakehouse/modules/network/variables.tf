# prefixes
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

# Azure resource:
variable "vnet_rg_name" {
  description = "Name of the virtual network resource group"
  type        = string
  default     = "virtualnetwork"
}

# variable for location
variable "location" {
  description = "Location of the resource - primary location."
  type        = string
}

variable "vnet_name" {
  description = "Specifies the name of the virtual virtual network"
  type        = string
  default     = "main"
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

variable "private_nsg_name" {
  description = "Specifies the name of the network security group"
  type        = string
  default     = "network-rules"
}

# Variable for defining NSG security rules
variable "nsg_security_rules" {
  description = "List of security rules for the Network Security Group."
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  # The default is set to an empty list because the actual rules will be defined in the tfvars file.
  default = []
}

variable "route_table" {
  description = "Specifies the name of the route table"
  type        = string
  default     = "route-table"
}

# Tags:
variable "default_tags" {
  type = map(any)
  default = {
    "Project"   = "Project-Lakehouse"
    "Owner"     = "sinwi"
    "CreatedBy" = "sinwi"
  }
}