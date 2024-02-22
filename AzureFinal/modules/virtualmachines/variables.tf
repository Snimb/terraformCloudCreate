# Azure resource:
variable "vm_rg_name" {
  description = "Name of the resource group"
  type        = string
  default = "managementvm"
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

### Module Variables ###
variable "module_jumpbox_subnet_id" {
  description = "The ID of the jumpbox subnet"
  type        = string
}

variable "module_user_assigned_identity_id" {
  description = "The ID of the user assigned identity"
  type        = string
}


variable "module_keyvault_name" {
  description = "Name of the Key Vault with module"
  type        = string
}

variable "module_secret_connection_string_names" {
  description = "A map of database names to the names of the Key Vault secrets containing their connection strings."
  type        = map(string)
}

variable "module_user_assigned_identity_client_id" {
  description = "The ID of the user assigned identity client ID"
  type        = string
}
