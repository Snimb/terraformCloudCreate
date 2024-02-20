# Azure resource:
variable "vm_rg_name" {
  description = "Name of the resource group"
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

# Location:
variable "location" {
  description = "Location of the resource - primary location."
  type        = string

}

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
