# variable for location
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

# Backend storage access key
/*riable "be_storage_account_access_key" {
  description = "The access key for the backend Azure Storage Account"
  type        = string
  sensitive   = true
}*/

# System resources:
variable "total_memory_mb" {
  description = "Total memory in MB for the PostgreSQL server"
}

variable "cpu_cores" {
  description = "Number of CPU cores for the PostgreSQL server"
}

### NETWORK ###
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

/*variable "hub_gateway_subnet_name" {
  description = "Specifies the name of the gateway subnet"
  default     = "HubGateway"
  type        = string
}

variable "hub_gateway_subnet_address_prefixes" {
  description = "Specifies the address prefix of the hub gateway subnet"
  type        = list(string)
}*/

/*variable "hub_vnet_address_space" {
  description = "Specifies the address space of the hub virtual virtual network"
  type        = list(string)
}*/

variable "hub_bastion_subnet_name" {
  description = "Specifies the name of the hub vnet AzureBastion subnet"
  default     = "AzureBastionSubnet"
  type        = string
}

variable "hub_bastion_subnet_address_prefixes" {
  description = "Specifies the address prefix of the hub bastion host subnet"
  type        = list(string)
}

/*variable "hub_firewall_subnet_name" {
  description = "Specifies the name of the azure firewall subnet"
  type        = string
  default     = "AzureFirewallSubnet"
}

variable "hub_firewall_subnet_address_prefixes" {
  description = "Specifies the address prefix of the azure firewall subnet"
  type        = list(string)
}*/

/*variable "hub_vnet_name" {
  description = "Specifies the name of the hub virtual virtual network"
  default     = "vnet-hub"
  type        = string
}*/

variable "spoke_vnet_name" {
  description = "Specifies the name of the spoke virtual virtual network"
  type        = string
  default     = "vnet-spoke"
}

variable "spoke_vnet_address_space" {
  description = "Specifies the address space of the spoke virtual virtual network"
  type        = list(string)
}

variable "jumpbox_subnet_name" {
  description = "Specifies the name of the jumpbox subnet"
  default     = "snet-jumpbox"
  type        = string
}

variable "psql_name" {
  description = "(Required) The name which should be used for this PostgreSQL Flexible Server."
  type        = string
  default     = "psql-server"
}

variable "jumpbox_subnet_address_prefix" {
  description = "Specifies the address prefix of the jumpbox subnet"
  type        = list(string)
}

/*variable "appgtw_subnet_name" {
  description = "Specifies the name of the application gateway subnet"
  type        = string
  default     = "appgtw"
}

variable "appgtw_address_prefixes" {
  description = "Specifies the address prefix of the application gateway"
  type        = list(string)
}*/

variable "psql_subnet_name" {
  description = "Specifies the name of the PostgreSQL server subnet"
  type        = string
  default     = "psqlSubnet"
}

variable "psql_address_prefixes" {
  description = "Specifies the address prefix of the postgreSQL server"
  type        = list(string)

}

/*variable "gateway_address_prefixes" {
  type = list(string)
}

variable "gatewaysubnet_address_prefixes" {
  type = list(string)
}*/


### POSTGRESQL ###
variable "psql_sku_name" {
  description = "(Optional) The SKU Name for the PostgreSQL Flexible Server. The name of the SKU, follows the tier + name pattern (e.g. B_Standard_B1ms, GP_Standard_D2s_v3, MO_Standard_E4s_v3). "
  type        = string
}

variable "psql_admin_login" {
  description = "(Optional) Admin username of the PostgreSQL server"
  type        = string
  default     = "postgres"
}

variable "psql_version" {
  description = "(Optional) The version of PostgreSQL Flexible Server to use. Required when create_mode is Default."
  type        = string
}

variable "psql_storage_mb" {
  description = "(Optional) The max storage allowed for the PostgreSQL Flexible Server. Possible values are 32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4193280, 4194304, 8388608, 16777216 and 33553408."
  type        = string
}

variable "backup_retention_days" {
  description = "The number of days backups are retained. Azure allows a minimum of 7 and a maximum of 35 days for backup retention."
  type        = string
}

variable "geo_redundant_backup_enabled" {
  description = "Indicates if geo-redundant backup is enabled for the Azure PostgreSQL Flexible Server"
  type        = bool
  default     = true
}

variable "auto_grow_enabled" {
  description = "Determines if storage auto-growth is enabled for the Azure PostgreSQL Flexible Server"
  type        = bool
  default     = false
}

/*variable "zone" {
  description = "The availability zone in which to deploy the Azure PostgreSQL Flexible Server"
  type        = string
}*/

variable "maintenance_window" {
  description = "Maintenance window for Azure PostgreSQL Flexible Server"
  type = object({
    day_of_week  = number
    start_hour   = number
    start_minute = number
  })
  default = {
    day_of_week  = 0  # Default to Sunday
    start_hour   = 3  # Default to 3 AM UTC
    start_minute = 30 # Default to 30 minutes past the hour
  }
}

variable "high_availability_mode" {
  description = "High availability mode for Azure PostgreSQL Flexible Server"
  type        = string
  default     = "ZoneRedundant" # Default to ZoneRedundant. Change to "SameZone" if needed.
}

variable "postgresql_configurations" {
  description = "PostgreSQL configurations to enable."
  type        = map(string)
  default = {
    # "pgbouncer.enabled" = "true",
    "azure.extensions" = "CITEXT,BTREE_GIST,PG_TRGM"
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

// ========================== Key Vault ==========================
data "azurerm_client_config" "current" {}

variable "kv_owner_object_id" {
  description = "(Required) object ids of the key vault owners who needs access to key vault."
  type        = string
  default     = "d0abdc5c-2ba6-4868-8387-d700969c786f"
}

variable "kv_sku_name" {
  description = "(Required) The Name of the SKU used for this Key Vault. Possible values are standard and premium."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.kv_sku_name)
    error_message = "The value of the sku name property of the key vault is invalid."
  }
}

variable "enabled_for_deployment" {
  description = "(Optional) Boolean flag to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault. Defaults to false."
  type        = bool
  default     = false
}

variable "enabled_for_disk_encryption" {
  description = " (Optional) Boolean flag to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys. Defaults to false."
  type        = bool
  default     = false
}

variable "enabled_for_template_deployment" {
  description = "(Optional) Boolean flag to specify whether Azure Resource Manager is permitted to retrieve secrets from the key vault. Defaults to false."
  type        = bool
  default     = false
}

variable "enable_rbac_authorization" {
  description = "(Optional) Boolean flag to specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions. Defaults to false."
  type        = bool
  default     = false
}

variable "purge_protection_enabled" {
  description = "(Optional) Is Purge Protection enabled for this Key Vault? Defaults to false."
  type        = bool
  default     = false
}

variable "soft_delete_retention_days" {
  description = "(Optional) The number of days that items should be retained for once soft-deleted. This value can be between 7 and 90 (the default) days."
  type        = number
  default     = 30
}

variable "bypass" {
  description = "(Required) Specifies which traffic can bypass the network rules. Possible values are AzureServices and None."
  type        = string
  default     = "AzureServices"

  validation {
    condition     = contains(["AzureServices", "None"], var.bypass)
    error_message = "The valut of the bypass property of the key vault is invalid."
  }
}

variable "kv_default_action" {
  description = "(Required) The Default Action to use when no rules match from ip_rules / virtual_network_subnet_ids. Possible values are Allow and Deny."
  type        = string
  default     = "Allow"

  validation {
    condition     = contains(["Allow", "Deny"], var.kv_default_action)
    error_message = "The value of the default action property of the key vault is invalid."
  }
}

variable "kv_ip_rules" {
  description = "(Optional) One or more IP Addresses, or CIDR Blocks which should be able to access the Key Vault."
  default     = []
}

variable "kv_virtual_network_subnet_ids" {
  description = "(Optional) One or more Subnet ID's which should be able to access this Key Vault."
  default     = [] # use this if virtual networking provisioned separately
}

variable "kv_key_permissions_full" {
  type        = list(string)
  description = "List of full key permissions, must be one or more from the following: backup, create, decrypt, delete, encrypt, get, import, list, purge, recover, restore, sign, unwrapKey, update, verify and wrapKey."
  default     = ["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
}

variable "kv_secret_permissions_full" {
  type        = list(string)
  description = "List of full secret permissions, must be one or more from the following: backup, delete, get, list, purge, recover, restore and set"
  default     = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]

}

variable "kv_certificate_permissions_full" {
  type        = list(string)
  description = "List of full certificate permissions, must be one or more from the following: backup, create, delete, deleteissuers, get, getissuers, import, list, listissuers, managecontacts, manageissuers, purge, recover, restore, setissuers and update"
  default     = ["Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"]
}

variable "kv_storage_permissions_full" {
  type        = list(string)
  description = "List of full storage permissions, must be one or more from the following: backup, delete, deletesas, get, getsas, list, listsas, purge, recover, regeneratekey, restore, set, setsas and update"
  default     = ["Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update", ]
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

### Management VM ###
variable "admin_username" {
  description = "The username of the VM"
  type        = string
}
