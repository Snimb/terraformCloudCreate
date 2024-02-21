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

# Location:
variable "location" {
  description = "Location of the resource - primary location."
  type        = string
}

### Virtual Network ###
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

### Log Analytics ###
/*variable "log_analytics_retention_days" {
  description = " (Optional) Specifies the workspace data retention in days. Range between 31 and 730."
  type        = number
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

variable "admin_public_key_path" {
  description = "Path to the public key to be used for SSH access."
  type        = string
}
*/
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

variable "zone" {
  description = "The availability zone in which to deploy the Azure PostgreSQL Flexible Server"
  type        = string
}

# create databases in PostgreSQL Server
variable "database_names" {
  type = list(string)
}

# System resources:
variable "total_memory_mb" {
  description = "Total memory in MB for the PostgreSQL server"
  type        = number
}

variable "cpu_cores" {
  description = "Number of CPU cores for the PostgreSQL server"
  type        = number
}

variable "psql_address_prefixes" {
  description = "Specifies the address prefix of the postgreSQL server"
  type        = list(string)
}

variable "psql_subnet_name" {
  description = "Specifies the name of the PostgreSQL server subnet"
  type        = string
  default     = "psqlSubnet"
}

variable "psql_name" {
  description = "(Required) The name which should be used for this PostgreSQL Flexible Server."
  type        = string
  default     = "psql-server"
}

variable "geo_redundant_backup_enabled" {
  description = "Indicates if geo-redundant backup is enabled for the Azure PostgreSQL Flexible Server"
  type        = bool
  default     = true
}


variable "private_dns_zone_name" {
  description = "Specifies the name of the PostgreSQL servers private DNS zone"
  type        = string
  default     = "postgres-server"
}

variable "postgresql_configurations" {
  description = "PostgreSQL configurations to enable."
  type        = map(string)
  default = {
    # "pgbouncer.enabled" = "true",
    "azure.extensions" = "CITEXT,BTREE_GIST,PG_TRGM"
  }
}

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

variable "auto_grow_enabled" {
  description = "Determines if storage auto-growth is enabled for the Azure PostgreSQL Flexible Server"
  type        = bool
  default     = false
}

/*variable "high_availability_mode" {
  description = "High availability mode for Azure PostgreSQL Flexible Server"
  type        = string
  default     = "ZoneRedundant" # Default to ZoneRedundant. Change to "SameZone" if needed.
}*/
