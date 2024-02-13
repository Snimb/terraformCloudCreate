# variable for location
variable "location" {
  default     = "West Europe" # Default location for all resources.
  description = "Location of the resource - primary location."
}

# Variables for the provider block:
variable "sp-subscription-id" {
  description = "Id of the azure subscription where all resources will be created"
  type        = string
}

variable "sp-tenant-id" {
  description = "Tenant Id of the azure account."
  type        = string
}
/*variable "sp-client-id" {
  description = "Client Id of A Service Principal or Azure Active Directory application registration used for provisioning azure resources."
  type        = string
}
variable "sp-client-secret" {
  description = "Secret of A Service Principal or Azure Active Directory application registration used for provisioning azure resources."
  type        = string
*/

# System resources:
variable "total_memory_mb" {
  description = "Total memory in MB for the PostgreSQL server"
  default     = 4096 # Example value, adjust as needed.
}

variable "cpu_cores" {
  description = "Number of CPU cores for the PostgreSQL server"
  default     = 2 # Example value, adjust as needed.
}

### POSTGRESQL ###
variable "psql_sku_name" {
  description = "(Optional) The SKU Name for the PostgreSQL Flexible Server. The name of the SKU, follows the tier + name pattern (e.g. B_Standard_B1ms, GP_Standard_D2s_v3, MO_Standard_E4s_v3). "
  type        = string
  default     = "B_Standard_B1ms"
}

variable "psql_admin_login" {
  description = "(Optional) Admin username of the PostgreSQL server"
  type        = string
  default     = "postgres"
}

variable "psql_version" {
  description = "(Optional) The version of PostgreSQL Flexible Server to use. Required when create_mode is Default."
  type        = string
  default     = "15"
}

variable "psql_storage_mb" {
  description = "(Optional) The max storage allowed for the PostgreSQL Flexible Server. Possible values are 32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4193280, 4194304, 8388608, 16777216 and 33553408."
  type        = string
  default     = "32768"
}

variable "backup_retention_days" {
  description = "The number of days backups are retained. Azure allows a minimum of 7 and a maximum of 35 days for backup retention."
  type        = string
  default     = "7"
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
  default     = "1"
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

variable "high_availability_mode" {
  description = "High availability mode for Azure PostgreSQL Flexible Server"
  type        = string
  default     = "ZoneRedundant" # Default to ZoneRedundant. Change to "SameZone" if needed.
}

variable "postgresql_configurations" {
  description = "PostgreSQL configurations to enable."
  type        = map(string)
  default = {
    "pgbouncer.enabled" = "true",
    "azure.extensions"  = "PG_TRGM"
  }
}




/*
### LOG ANALYTICS ###
variable "log_analytics_workspace_rg_name" {
  description = "(Required) Specifies the resource group name of the log analytics workspace"
  type        = string
  default     = "rg-workspace-dev"
}

variable "log_analytics_workspace_name" {
  description = "(Required) Specifies the name of the log analytics workspace"
  type        = string
  default     = "workspace-workspace1-dev"
}

variable "log_analytics_workspace_location" {
  description = "(Required) Specifies the location of the log analytics workspace"
  type        = string
  default     = "West Europe"
}

variable "log_analytics_workspace_sku" {
  description = "(Optional) Specifies the sku of the log analytics workspace"
  type        = string
  default     = "PerGB2018"

  validation {
    condition     = contains(["Free", "Standalone", "PerNode", "PerGB2018"], var.log_analytics_workspace_sku)
    error_message = "The log analytics sku is incorrect."
  }
}

variable "solution_plan_map" {
  description = "(Required) Specifies solutions to deploy to log analytics workspace"
  type        = map(any)
  default = {
    ContainerInsight product = "OMSGallery/ContainerInsights"
      publisher = "Microsoft"
    }
  }
}

variable "log_analytics_retention_days" {
  description = " (Optional) Specifies the workspace data retention in days. Possible values are either 7 (Free Tier only) or range between 30 and 730."
  type        = number
  default     = 7
}

variable "log_analytics_tags" {
  description = "(Optional) Specifies the tags of the log analytics"
  type        = map(any)
  default     = {}
}*/
