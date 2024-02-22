# Azure resource:
variable "diag_rg_name" {
  description = "Name of the resource group"
  type        = string
  default     = "workspace"
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


### LOG ANALYTICS ###
variable "log_analytics_workspace_sku" {
  description = "(Optional) Specifies the sku of the log analytics workspace"
  type        = string
  default     = "PerGB2018"
}

variable "solution_plan_map" {
  description = "(Required) Specifies solutions to deploy to log analytics workspace"
  type        = map(any)
  default = {
    ContainerInsight = {
      product   = "Microsoft.ContainerService/ContainerInsights"
      publisher = "Microsoft"
    }
  }
}

variable "log_analytics_retention_days" {
  description = " (Optional) Specifies the workspace data retention in days. Range between 31 and 730."
  type        = number
}

variable "log_analytics_workspace_name" {
  description = "(Required) Specifies the name of the log analytics workspace"
  type        = string
  default     = "log-analytics"
}

### storage account variables ###
/*variable "storage_name" {
  description = "(Required) Specifies the name of the storage account"
  type        = string
}

variable "storage_account_kind" {
  description = "(Optional) Specifies the account kind of the storage account"
  type        = string

  validation {
    condition     = contains(["Storage", "StorageV2", "BlobStorage", "BlockBlobStorage", "FileStorage"], var.storage_account_kind)
    error_message = "The account kind of the storage account is invalid."
  }
}

variable "storage_access_tier" {
  description = "(Optional) Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are Hot and Cool, defaults to Hot."
  type        = string

  validation {
    condition     = contains(["Hot", "Cool"], var.storage_access_tier)
    error_message = "The access tier of the storage account is invalid."
  }
}

variable "storage_account_retention_days" {
  type        = number
  description = "The number of days to retain logs and metrics in the storage account."
}

variable "storage_account_tier" {
  description = "(Optional) Specifies the account tier of the storage account"
  type        = string

  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "The account tier of the storage account is invalid."
  }
}

variable "storage_replication_type" {
  description = "(Optional) Specifies the replication type of the storage account"
  type        = string

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.storage_replication_type)
    error_message = "The replication type of the storage account is invalid."
  }
}

variable "storage_is_hns_enabled" {
  description = "(Optional) Specifies the replication type of the storage account"
  type        = bool
}

variable "storage_default_action" {
  description = "Allow or disallow public access to all blobs or containers in the storage accounts. The default interpretation is true for this property."
  type        = string
}

variable "storage_ip_rules" {
  description = "Specifies IP rules for the storage account"
  default     = []
  type        = list(string)
}

variable "storage_virtual_network_subnet_ids" {
  description = "Specifies a list of resource ids for subnets"
  default     = []
  type        = list(string)
}

variable "storage_file_share_name" {
  description = " (Required) The name of the File Share within the Storage Account where Files should be stored"
  type        = string
}

variable "pe_blob_subresource_names" {
  description = "(Optional) Specifies a subresource names which the Private Endpoint is able to connect to Blob."
  type        = list(string)
  default     = ["blob"]
}

variable "pe_blob_private_dns_zone_group_name" {
  description = "(Required) Specifies the Name of the Private DNS Zone Group for Blob. "
  type        = string
  default     = "BlobPrivateDnsZoneGroup"
}
*/

### Virtual Network module variables ### 
variable "module_vnet_id" {
  description = "ID of the virtual network with module"
  type        = string
}

variable "module_vnet" {
  description = "The resource group of the virtual network"
  type = object({
    name                = string
    id                  = string
    resource_group_name = string
  })
}

### PostgreSQL Server module variables ###
variable "module_postgres_fs_name" {
  description = "Name of the postgresql server with module"
  type        = string
}

variable "module_postgres_fs_id" {
  description = "ID of the postgresql server with module"
  type        = string
}

variable "module_postgres_fs" {
  description = "The obeject of the postgres server"
  type = object({
    name                = string
    id                  = string
    resource_group_name = string
  })
}

### Key Vault module variables ###
variable "module_keyvault_name" {
  description = "Name of the Key Vault with module"
  type        = string
}

variable "module_keyvault_id" {
  description = "ID of the Key Vault server with module"
  type        = string
}

variable "module_keyvault" {
  description = "The object of the Key Vault"
  type = object({
    name                = string
    id                  = string
    resource_group_name = string
  })
}
