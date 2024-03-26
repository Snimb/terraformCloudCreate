# Azure resource:
variable "vm_rg_name" {
  description = "Name of the resource group"
  type        = string
  default     = "managementvm"
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

data "azurerm_client_config" "current" {}

# data "azurerm_subscriptions" "available" {}

### Management VM ###
variable "vm_admin_username" {
  description = "The username of the VM"
  type        = string
}

variable "admin_ssh_key_username" {
  description = "The username of the SSH key admin"
  type        = string
}

variable "vm_size" {
  description = "The size og the virtual machine"
  type        = string
}

variable "admin_public_key_path" {
  description = "Path to the public key to be used for SSH access."
  type        = string
}

variable "os_disk_caching" {
  description = "Caching type for the OS Disk."
  type        = string
  default     = "ReadWrite"
}

variable "storage_account_type" {
  description = "Type of storage account for the OS disk."
  type        = string
}

variable "image_publisher" {
  description = "Publisher of the VM image."
  type        = string
}

variable "image_offer" {
  description = "Offer of the VM image."
  type        = string
}

variable "image_sku" {
  description = "SKU of the VM image."
  type        = string
}

variable "image_version" {
  description = "Version of the VM image."
  type        = string
  default     = "latest"
}

variable "vm_name" {
  description = "The name of the VM"
  type        = string
  default     = "management"
}

variable "sas_token" {
  description = "SAS Token for accessing Azure Blob Storage"
  type        = string
}

### Module Variables ###
variable "module_jumpbox_subnet_id" {
  description = "The ID of the jumpbox subnet"
  type        = string
}

variable "module_keyvault_id" {
  description = "ID of the Key Vault server with module"
  type        = string
}

variable "module_keyvault_name" {
  description = "Name of the Key Vault with module"
  type        = string
}

variable "module_secret_connection_string_names" {
  description = "A map of database names to the names of the Key Vault secrets containing their connection strings."
  type        = list(string)
}

variable "module_keyvault" {
  description = "The object of the Key Vault"
  type = object({
    name                = string
    id                  = string
    resource_group_name = string
  })
}

variable "module_postgres_fs_database_names" {
  type        = list(string) # Adjust the type based on the actual structure you expect
  description = "List of PostgreSQL database configurations"
}

variable "module_postgresql_configurations" {
  description = "PostgreSQL configurations to enable."
  type        = map(string)
}

variable "module_log_analytics_workspace_object" {
  description = "The entire Log Analytics Workspace object."
  type = any # You could also use a more specific type structure
}

variable "module_log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace."
  type        = string
}

variable "module_storage_account_id" {
description = "The ID of the storage account."
type = string  
}