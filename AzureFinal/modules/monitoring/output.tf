# Resource group:
output "resource_group_name" {
  value = azurerm_resource_group.diag.name # Outputs the name of the created resource group.
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

output "storage_account_connection_string" {
  value = azurerm_storage_account.st.primary_connection_string
}

/*output "azurerm_function_app_host_keys" {
value = azurerm_function_app_host_keys.hostkeys
}

output "sas_url_query_string" {
  value = data.azurerm_storage_account_blob_container_sas.func_app_container_sas.sas
}*/