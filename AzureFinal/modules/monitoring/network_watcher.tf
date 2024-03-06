resource "azurerm_network_watcher" "network_watcher" {
  name                = lower("${var.network_watcher_prefix}-${random_pet.name_prefix.id}-${var.network_watcher_name}-${local.environment}")
  location            = var.location
  resource_group_name = azurerm_resource_group.diag.name
}

resource "azurerm_network_watcher_flow_log" "nw_flow_log" {
  for_each             = local.nsg_ids
  name                 = lower("${var.network_watcher_prefix}-${each.key}-${local.environment}")
  network_watcher_name = azurerm_network_watcher.network_watcher.name
  resource_group_name  = azurerm_network_watcher.network_watcher.resource_group_name

  network_security_group_id = each.value
  storage_account_id        = azurerm_storage_account.st.id
  enabled                   = true

  retention_policy {
    enabled = true
    days    = var.network_watcher_retention_days // Adjust based on your retention requirements
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = azurerm_log_analytics_workspace.workspace.workspace_id
    workspace_region      = var.location
    workspace_resource_id = azurerm_log_analytics_workspace.workspace.id
    interval_in_minutes   = var.network_watcher_traffic_analytics_interval_in_minutes
  }
}
