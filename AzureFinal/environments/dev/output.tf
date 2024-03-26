
output "client_id" {
  value = data.azurerm_client_config.current.client_id
}

output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "object_id" {
  value = data.azurerm_client_config.current.object_id
}

output "subscription_id" {
  value = data.azurerm_client_config.current.subscription_id
}

output "key_vault_uri" {
  value = module.monitoring.key_vault_uri
}

output "storage_account_connection_string" {
  value     = module.monitoring.storage_account_connection_string
  sensitive = true
}

output "http_trigger_url" {
  value     = module.monitoring.http_trigger_url
  sensitive = true
}

output "func_app_primary_key" {
  value     = module.monitoring.func_app_primary_key
  sensitive = true
}

output "func_app_default_keys" {
  value     = module.monitoring.func_app_default_keys
  sensitive = true
}

output "postgresql_configurations" {
  value = module.database.psql_configurations
}
