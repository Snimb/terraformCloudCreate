/*
resource "azurerm_sentinel_log_analytics_workspace_onboarding" "sentinel_onboarding" {
  workspace_id = azurerm_log_analytics_workspace.workspace.id
}

resource "azurerm_sentinel_data_connector_azure_active_directory" "sentinel_data_connector_ad" {
  name                       = "sentinel-data-connector-ad"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding.workspace_id
}

resource "azurerm_sentinel_data_connector_microsoft_cloud_app_security" "sentinel_data_connector_cas" {
  name                       = "sentinel-data-connector-cas"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding.workspace_id
}

resource "azurerm_sentinel_alert_rule_ms_security_incident" "cloud_app_security_rule" {
  name                       = "cloud-app-ms-security-incident-alert-rule"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.sentinel_onboarding.workspace_id
  product_filter             = "Microsoft Cloud App Security"
  display_name               = "Cloud App Security Rule"
  severity_filter            = ["High"]
}
*/