# Networking - Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "diag_vnet" {
  name                       = "DiagnosticsSettings"
  target_resource_id         = var.module_vnet_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id
  storage_account_id         = azurerm_storage_account.st.id

  enabled_log {
    category_group = "allLogs"
  }


  metric {
    category = "AllMetrics"
    enabled  = true
  }

  depends_on = [
    var.module_vnet,
    azurerm_log_analytics_workspace.workspace,
  ]
}

# Key Vault - Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "diag_kv" {
  name                       = lower("${var.diag_prefix}-${random_pet.name_prefix.id}-${var.module_keyvault_name}")
  target_resource_id         = var.module_keyvault_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id
  storage_account_id         = azurerm_storage_account.st.id

  enabled_log {
    category_group = "allLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }

  depends_on = [
    var.module_keyvault,
    azurerm_log_analytics_workspace.workspace,
  ]
}

# PostgreSQL Server - Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "diag_psql" {
  name                       = lower("${var.diag_prefix}-${random_pet.name_prefix.id}-${var.module_postgres_fs_name}")
  target_resource_id         = var.module_postgres_fs_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id
  storage_account_id         = azurerm_storage_account.st.id

  enabled_log {
    category_group = "allLogs"

  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }


  depends_on = [
    var.module_postgres_fs,
    azurerm_log_analytics_workspace.workspace,
  ]
}

resource "azurerm_monitor_diagnostic_setting" "nsg_diagnostic_setting" {
  for_each = local.nsg_ids

  name                       = lower("${var.diag_prefix}-${random_pet.name_prefix.id}-${each.key}")
  target_resource_id         = each.value
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id
  storage_account_id         = azurerm_storage_account.st.id

  enabled_log {
    category = "NetworkSecurityGroupRuleCounter"
  }

  enabled_log {
    category = "NetworkSecurityGroupEvent"
  }
}

# Storage Account - Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "diag_st" {
  name                       = lower("${var.diag_prefix}-${azurerm_storage_account.st.name}")
  target_resource_id         = azurerm_storage_account.st.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id

  metric {
    category = "AllMetrics"
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
    category = "AllMetrics"
    enabled  = true
  }

  depends_on = [
    azurerm_storage_account.st,
    azurerm_log_analytics_workspace.workspace,
  ]
}

# Function App diagnostic settings
resource "azurerm_monitor_diagnostic_setting" "func_app_diag" {
  name                       = "functionapp-diagnostics"
  target_resource_id         = azurerm_linux_function_app.diag_app.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id

  enabled_log {
    category = "FunctionAppLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}