# Create Diagnostics Settings for Networking
/*resource "azurerm_monitor_diagnostic_setting" "diag_vnet" {
  name                       = "DiagnosticsSettings"
  target_resource_id         = azurerm_virtual_network.vnet.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id

  log {
    category = "VMProtectionAlerts"
    enabled  = true

    retention_policy {
      enabled = true
      days    = var.vnet_log_analytics_retention_days
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
      days    = var.log_analytics_retention_days
    }
  }
  depends_on = [
    azurerm_virtual_network.vnet,
    azurerm_log_analytics_workspace.workspace,
  ]
}

# create diagnostic setting for key vault
resource "azurerm_monitor_diagnostic_setting" "diag_kv" {
  name                       = lower("${var.diag_prefix}-${azurerm_key_vault.kv.name}")
  target_resource_id         = azurerm_key_vault.kv.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id
  enabled_log {
    category = "AuditEvent"

    retention_policy {
      days    = 0
      enabled = true
    }
  }
  enabled_log {
    category = "AzurePolicyEvaluationDetails"

    retention_policy {
      days    = 0
      enabled = true
    }
  }

  metric {
    category = "AllMetrics"
    retention_policy {
      enabled = true
    }
  }
  lifecycle {
    ignore_changes = [
      log_analytics_destination_type,
    ]
  }
  depends_on = [
    azurerm_key_vault.kv,
    azurerm_log_analytics_workspace.workspace
  ]
}

# Create diagnostic settings for PostgreSQL server
resource "azurerm_monitor_diagnostic_setting" "diag_psql" {
  name                       = lower("${var.diag_prefix}-${azurerm_postgresql_flexible_server.default.name}")
  target_resource_id         = azurerm_postgresql_flexible_server.default.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id
  enabled_log {
    category = "PostgreSQLFlexDatabaseXacts"

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  enabled_log {
    category = "PostgreSQLFlexQueryStoreRuntime"

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  enabled_log {
    category = "PostgreSQLFlexQueryStoreWaitStats"

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  enabled_log {
    category = "PostgreSQLFlexSessions"

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  enabled_log {
    category = "PostgreSQLFlexTableStats"

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  enabled_log {
    category = "PostgreSQLLogs"

    retention_policy {
      days    = 0
      enabled = true
    }
  }
  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }
  lifecycle {
    ignore_changes = [
      # log
    ]
  }
  depends_on = [
    azurerm_postgresql_flexible_server.default,
    azurerm_log_analytics_workspace.workspace
  ]
}

# Create diagnostic settings for Storage Account
resource "azurerm_monitor_diagnostic_setting" "diag_st" {
  name                       = lower("${var.diag_prefix}-${azurerm_storage_account.st.name}")
  target_resource_id         = azurerm_storage_account.st.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id

  metric {
    category = "Transaction"
    retention_policy {
      enabled = true
    }
  }

  lifecycle {
    ignore_changes = [
      log,
      metric
    ]
  }
  depends_on = [
    azurerm_storage_account.st,
    azurerm_log_analytics_workspace.workspace
  ]
}

# Create diagnostic settings at the blob level
resource "azurerm_monitor_diagnostic_setting" "diag_st_container" {
  name                       = lower("${var.diag_prefix}-${azurerm_storage_account.st.name}-blob")
  target_resource_id         = "${azurerm_storage_account.st.id}/blobServices/default/"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id
  log {
    category = "StorageRead"
    enabled  = true
  }

  log {
    category = "StorageWrite"
    enabled  = true
  }

  log {
    category = "StorageDelete"
    enabled  = true
  }

  metric {
    category = "Transaction"
  }

  lifecycle {
    ignore_changes = [
      log,
      metric
    ]
  }
  depends_on = [
    azurerm_storage_account.st,
    azurerm_log_analytics_workspace.workspace
  ]
}*/

# Networking - Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "diag_vnet" {
  name                       = "DiagnosticsSettings"
  target_resource_id         = azurerm_virtual_network.vnet.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id

  enabled_log {
    category = "AuditEvent"
  }

  enabled_log {
    category = "AzurePolicyEvaluationDetails"
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
    category = "AuditEvent"
  }

  enabled_log {
    category = "AzurePolicyEvaluationDetails"
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
resource "azurerm_monitor_diagnostic_setting" "diag_st" {
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

# Storage Management Policy for Storage Account
resource "azurerm_storage_management_policy" "st_mgmt_policy" {
  storage_account_id = azurerm_storage_account.st.id

  rule {
    name    = "retention-policy"
    enabled = true
    filters {
      blob_types   = ["blockBlob"]
      prefix_match = ["logs/", "metrics/"]
    }
    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = var.storage_account_retention_days
      }
      snapshot {
        delete_after_days_since_creation_greater_than = var.storage_account_retention_days
      }
    }
  }
}
