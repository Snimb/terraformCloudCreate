# Azure resource:
variable "vnet_rg_name" {
  description = "Name of the virtual network resource group"
  type        = string
  default = "virtualnetwork"
}

# variable for location
variable "location" {
  description = "Location of the resource - primary location."
  type        = string
}

# Tags:
variable "default_tags" {
  type = map(any)
  default = {
    "Project"   = "Project-postgres"
    "Owner"     = "sinwi"
    "CreatedBy" = "sinwi"
  }
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

variable "hub_bastion_subnet_name" {
  description = "Specifies the name of the hub vnet AzureBastion subnet"
  default     = "AzureBastionSubnet"
  type        = string
}

variable "hub_bastion_subnet_address_prefixes" {
  description = "Specifies the address prefix of the hub bastion host subnet"
  type        = list(string)
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

variable "jumpbox_subnet_name" {
  description = "Specifies the name of the jumpbox subnet"
  default     = "snet-jumpbox"
  type        = string
}

variable "jumpbox_subnet_address_prefix" {
  description = "Specifies the address prefix of the jumpbox subnet"
  type        = list(string)
}

variable "bastion_name" {
  description = "Specifies the name of the bastion instance"
  default     = "bastion"
  type        = string
}

variable "nsg_name" {
  description = "Specifies the name of the network security group"
  type = string
  default = "network-rules"
}
