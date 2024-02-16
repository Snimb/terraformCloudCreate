output "resource_group_name_default" {
  value = azurerm_resource_group.default.name # Outputs the name of the created resource group.
}

output "azurerm_postgresql_flexible_server" {
  value = azurerm_postgresql_flexible_server.default.name # Outputs the name of the created PostgreSQL Flexible Server.
}

# This allows you to easily retrieve and use the database name in other parts of your infrastructure or in external tools.
output "postgresql_flexible_server_database_name" {
  value = azurerm_postgresql_flexible_server_database.default.name # Output the name of the PostgreSQL Flexible Server Database
}

# This password may be needed for administrative access or configuration changes to the database.
output "postgresql_flexible_server_admin_password" {
  sensitive = true                                                              # Marked as sensitive to prevent it from being displayed in logs or console output, ensuring security
  value     = azurerm_postgresql_flexible_server.default.administrator_password # Output the admin password for the PostgreSQL Flexible Server
}


### LOG ANALYTICS ###
output "log_analytics_workspace_id" {
  value       = azurerm_log_analytics_workspace.workspace.id
  description = "Specifies the resource id of the log analytics workspace"
}

output "log_analytics_workspace_location" {
  value       = azurerm_log_analytics_workspace.workspace.location
  description = "Specifies the location of the log analytics workspace"
}

output "log_analytics_workspace_name" {
  value       = azurerm_log_analytics_workspace.workspace.name
  description = "Specifies the name of the log analytics workspace"
}

output "log_analytics_workspace_resource_group_name" {
  value       = azurerm_log_analytics_workspace.workspace.resource_group_name
  description = "Specifies the name of the resource group that contains the log analytics workspace"
}

output "log_analytics_workspace_workspace_id" {
  value       = azurerm_log_analytics_workspace.workspace.workspace_id
  description = "Specifies the workspace id of the log analytics workspace"
}

output "log_analytics_workspace_primary_shared_key" {
  value       = azurerm_log_analytics_workspace.workspace.primary_shared_key
  description = "Specifies the workspace key of the log analytics workspace"
  sensitive   = true
}


### virtual netowrking ###
output "vnet_name" {
  description = "Specifies the name of the virtual network"
  value       = azurerm_virtual_network.vnet.name
}

output "vnet_id" {
  description = "Specifies the resource id of the virtual network"
  value       = azurerm_virtual_network.vnet.id
}

output "subnet_gateway_id" {
  description = "Specifies the resource id of the gateway subnets"
  value       = azurerm_subnet.gateway.id
}
output "subnet_appgtw_id" {
  description = "Specifies the resource id of the appgtw subnets"
  value       = azurerm_subnet.appgtw.id
}
output "subnet_psql_id" {
  description = "Specifies the resource id of the psql subnets"
  value       = azurerm_subnet.psql.id
}