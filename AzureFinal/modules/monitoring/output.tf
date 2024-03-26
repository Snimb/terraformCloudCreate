# Resource group:
output "resource_group_name" {
  value = azurerm_resource_group.diag.name # Outputs the name of the created resource group.
}

### LOG ANALYTICS ###
output "log_analytics_workspace" {
  value = azurerm_log_analytics_workspace.workspace
  description = "The entire Log Analytics Workspace object."
}

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

output "log_analytics_workspace_primary_shared_key" {
  value       = azurerm_log_analytics_workspace.workspace.primary_shared_key
  description = "Specifies the workspace key of the log analytics workspace"
  sensitive   = true
}

output "storage_account_connection_string" {
  value = azurerm_storage_account.st.primary_connection_string
  sensitive = true
}

 output "key_vault_uri" {
   value = var.module_keyvault.vault_uri
 }

 output "http_trigger_url" {
  value = "https://${azurerm_linux_function_app.diag_app.default_hostname}/api/AutoScaleDB?code=${data.azurerm_function_app_host_keys.func_app_keys.default_function_key}"
}

output "func_app_primary_key" {
  value = data.azurerm_function_app_host_keys.func_app_keys.primary_key
  depends_on = [ azurerm_linux_function_app.diag_app,
  azurerm_monitor_action_group.ag ]
}

output "func_app_default_keys" {
  value = data.azurerm_function_app_host_keys.func_app_keys.default_function_key
  depends_on = [ azurerm_linux_function_app.diag_app,
  azurerm_monitor_action_group.ag ]
}

output "subnet_funcapp_id" {
  value = azurerm_subnet.func_app.id
  description = "Funcapp Subnet ID"
}

output "storage_account_id" {
  value = azurerm_storage_account.st.id
  description = "Specifies the resource id of the storage account"
}