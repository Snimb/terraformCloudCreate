# Networking - Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "diag_vnet" {
  name                       = "DiagnosticsSettings"
  target_resource_id         = azurerm_virtual_network.vnet.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id

  enabled_log {
    category_group = "allLogs"
  }


  metric {
    category = "AllMetrics"
    enabled  = true
  }

  depends_on = [
    azurerm_virtual_network.vnet,
    azurerm_log_analytics_workspace.workspace,
  ]
}

# Key Vault - Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "diag_kv" {
  name                       = lower("${var.diag_prefix}-${azurerm_key_vault.kv.name}")
  target_resource_id         = azurerm_key_vault.kv.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id

  enabled_log {
    category_group = "allLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }

  depends_on = [
    azurerm_key_vault.kv,
    azurerm_log_analytics_workspace.workspace,
  ]
}

# PostgreSQL Server - Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "diag_psql" {
  name                       = lower("${var.diag_prefix}-${azurerm_postgresql_flexible_server.default.name}")
  target_resource_id         = azurerm_postgresql_flexible_server.default.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id

  enabled_log {
    category = "PostgreSQLLogs"
  }
  # Additional logs and metrics as needed

  depends_on = [
    azurerm_postgresql_flexible_server.default,
    azurerm_log_analytics_workspace.workspace,
  ]
}

# Storage Account - Diagnostic Settings
/*resource "azurerm_monitor_diagnostic_setting" "diag_st" {
  name                       = lower("${var.diag_prefix}-${azurerm_storage_account.st.name}")
  target_resource_id         = azurerm_storage_account.st.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id

  metric {
    category = "Transaction"
    enabled  = true
  }

  depends_on = [
    azurerm_storage_account.st,
    azurerm_log_analytics_workspace.workspace,
  ]
}

# Blob Service - Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "diag_st_container" {
  name                       = lower("${var.diag_prefix}-${azurerm_storage_account.st.name}-blob")
  target_resource_id         = "${azurerm_storage_account.st.id}/blobServices/default/"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }

  metric {
    category = "Transaction"
    enabled  = true
  }

  depends_on = [
    azurerm_storage_account.st,
    azurerm_log_analytics_workspace.workspace,
  ]
}
*/