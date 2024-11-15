# prefixes
variable "rg_prefix" {
  type        = string
  default     = "rg"
  description = "Prefix of the resource group name that's combined with name of the resource group."
}

# Azure resource:
variable "databricks_rg_name" {
  description = "Name of the virtual network resource group"
  type        = string
  default     = "databricks"
}

# variable for location
variable "location" {
  description = "Location of the resource - primary location."
  type        = string
}

variable "databricks_ws_sku" {
  description = "SKU of the databricks workspace"
  type        = string
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
