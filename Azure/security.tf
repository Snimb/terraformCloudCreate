/*resource "azurerm_monitor_diagnostic_setting" "example" {
  name                       = "example-setting"
  target_resource_id         = azurerm_postgresql_flexible_server.default.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  log {
    category = "PostgreSQLLogs"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 30
    }
  }
}
*/