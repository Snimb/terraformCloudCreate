# prefixes
variable "rg_prefix" {
  type        = string
  default     = "rg"
  description = "Prefix of the resource group name that's combined with name of the resource group."
}

# Azure resource:
variable "lakehouse_rg_name" {
  description = "Name of the virtual network resource group"
  type        = string
  default     = "virtualnetwork"
}

# variable for location
variable "location" {
  description = "Location of the resource - primary location."
  type        = string
}

variable "storage_account_names" {
  type        = list(string)
  description = "Names of additional storage accounts to create"
  default     = []
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