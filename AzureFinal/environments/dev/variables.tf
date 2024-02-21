# Variables for the provider block:
variable "sp-subscription-id" {
  description = "Id of the azure subscription where all resources will be created"
  type        = string
  sensitive   = true

}

variable "sp-tenant-id" {
  description = "Tenant Id of the azure account."
  type        = string
  sensitive   = true

}

variable "sp-client-id" {
  description = "Client Id of A Service Principal or Azure Active Directory application registration used for provisioning azure resources."
  type        = string
  sensitive   = true

}

variable "sp-client-secret" {
  description = "Secret of A Service Principal or Azure Active Directory application registration used for provisioning azure resources."
  type        = string
  sensitive   = true

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

# Location:
variable "location" {
  description = "Location of the resource - primary location."
  type        = string
}

variable "hub_bastion_subnet_address_prefixes" {
  description = "Specifies the address prefix of the hub bastion host subnet"
  type        = list(string)
}

variable "vnet_address_space" {
  description = "Specifies the address space of the virtual virtual network"
  type        = list(string)
}

variable "jumpbox_subnet_address_prefix" {
  description = "Specifies the address prefix of the jumpbox subnet"
  type        = list(string)
}

variable "vnet_prefix" {
  type        = string
  default     = "vnet"
  description = "Prefix of the vnet name."
}

variable "vnet_name" {
  description = "Specifies the name of the virtual virtual network"
  type        = string
  default     = "vnet"
}