# Azure resource:
variable "db_rg_name" {
  description = "Name of the resource group"
  type        = string
  default = "postgresql"
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

variable "sp-tenant-id" {
  description = "Azure service principal tenant ID"
}

data "azurerm_client_config" "current" {}

### POSTGRESQL ###
variable "psql_name" {
  description = "(Required) The name which should be used for this PostgreSQL Flexible Server."
  type        = string
  default     = "psql-server"
}

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

variable "zone" {
  description = "The availability zone in which to deploy the Azure PostgreSQL Flexible Server"
  type        = string
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

/*variable "high_availability_mode" {
  description = "High availability mode for Azure PostgreSQL Flexible Server"
  type        = string
  default     = "ZoneRedundant" # Default to ZoneRedundant. Change to "SameZone" if needed.
}*/

variable "postgresql_configurations" {
  description = "PostgreSQL configurations to enable."
  type        = map(string)
  default = {
    # "pgbouncer.enabled" = "true",
    "azure.extensions" = "CITEXT,BTREE_GIST,PG_TRGM"
  }
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

# Network variables: 
variable "psql_subnet_name" {
  description = "Specifies the name of the PostgreSQL server subnet"
  type        = string
  default     = "psqlSubnet"
}

variable "psql_address_prefixes" {
  description = "Specifies the address prefix of the postgreSQL server"
  type        = list(string)
}

variable "private_dns_zone_name" {
  description = "Specifies the name of the PostgreSQL servers private DNS zone"
  type        = string
  default     = "postgres-server"
}

variable "module_vnet_id" {
  description = "ID of the virtual network with module"
  type        = string
}

variable "module_vnet_name" {
  description = "Name of the virtual network with module"
  type        = string
}

# In modules/database/variables.tf
variable "module_nsg_id" {
  description = "The ID of the Network Security Group"
  type        = string
}

variable "module_vnet" {
  description = "The resource group of the virtual network"
  type        = object({
    name = string
    id = string
    resource_group_name = string
  })
}

variable "module_vnet_resource_grp" {
  description = "Name of the virtual network resource group with module"
  type        = string
}

