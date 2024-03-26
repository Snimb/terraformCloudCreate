# Azure resource:
variable "diag_rg_name" {
  description = "Name of the resource group"
  type        = string
  default     = "diagnostics"
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

variable "network_watcher_name" {
  description = "(Required) Specifies the name of the network watcher"
  type        = string
  default     = "network-watcher"
}

variable "network_watcher_retention_days" {
  description = " (Optional) Specifies the data retention in days. Range between 31 and 730."
  type        = number
}

variable "network_watcher_traffic_analytics_interval_in_minutes" {
  type = number
}

variable "email_receivers" {
  description = "List of email receivers for the action group"
  type = list(object({
    name          = string
    email_address = string
  }))
}

variable "sku_name_service_plan" {
  description = "The SKU name of the service plan."
  type        = string
}


### storage account variables ###
variable "storage_name" {
  description = "(Required) Specifies the name of the storage account"
  type        = string
  default     = "logstorage"
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

variable "storage_file_share_name" {
  description = " (Required) The name of the File Share within the Storage Account where Files should be stored"
  type        = string
  default     = "file-share"
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

variable "funcapp_subnet_address_prefix" {
  description = "Specifies the address prefix of the funcapp subnet"
  type        = list(string)
}

variable "funcapp_subnet_name" {
  description = "Specifies the name of the funcapp subnet"
  default     = "funcapp"
  type        = string
}

variable "funcapp_allways_on" {
  description = "Specifies if the function app should be allways on"
  type = string
}

variable "security_center_pricing" {
  description = "A list of Security Center pricing configurations"
  type = list(object({
    tier          = string
    resource_type = string
    subplan       = string
  }))
  default = []
}

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

variable "module_vnet_resource_grp" {
  description = "The object of the virtual network with module"
  type        = string
}

variable "module_vnet_name" {
  description = "Name of the virtual network with module"
  type        = string
}

variable "module_nsg_id_jumpbox" {
  type = string
}

variable "module_subnet_jumpbox_id" {
  description = "ID of the subnet jumpbox with module"
  type        = string
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

variable "module_subnet_psql_id" {
  description = "ID of the subnet psql with module"
  type = string
}

variable "module_nsg_id_psql" {
  type = string
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
    vault_uri           = string
  })
}
