data "azurerm_subscription" "current" {}

terraform {
  required_providers {
    azapi = {
      source = "Azure/azapi"
    }
  }
}

resource "azurerm_subscription_policy_assignment" "mcsb_assignment" {
  name                 = "mcsb"
  display_name         = "Microsoft Cloud Security Benchmark"
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/1f3afdf9-d0c9-4c3d-847f-89da613e70a8"
  subscription_id      = data.azurerm_subscription.current.id
}

resource "azurerm_security_center_subscription_pricing" "mdc_pricing" {
  for_each = { for idx, pricing in var.security_center_pricing : idx => pricing }

  tier          = each.value.tier
  resource_type = each.value.resource_type
}

resource "azurerm_security_center_setting" "setting_mde" {
  setting_name = "WDATP"
  enabled      = true
}

resource "azurerm_advanced_threat_protection" "advanced_threat_proctec" {
  target_resource_id = var.module_postgres_fs_id
  enabled            = true
}

resource "azapi_resource" "setting_agentless_vm" {
  type      = "Microsoft.Security/vmScanners@2022-03-01-preview"
  name      = "default"
  parent_id = data.azurerm_subscription.current.id
  body = jsonencode({
    properties = {
      scanningMode = "Default"
    }
  })
  schema_validation_enabled = false
}

resource "azapi_update_resource" "setting_cspm" {
  type      = "Microsoft.Security/pricings@2023-01-01"
  name      = "CloudPosture"
  parent_id = data.azurerm_subscription.current.id
  body = jsonencode({
    properties = {
      pricingTier = "Standard"
      extensions = [
        {
          name      = "SensitiveDataDiscovery"
          isEnabled = "True"
        },
        {
          name      = "ContainerRegistriesVulnerabilityAssessments"
          isEnabled = "True"
        }
      ]
    }
  })
}

resource "azurerm_security_center_contact" "mdc_contact" {
  email               = "simonwilliams@outlook.dk"
  phone               = "+4520627530"
  alert_notifications = true
  alerts_to_admins    = true
}

resource "azurerm_security_center_auto_provisioning" "auto-provisioning" {
  auto_provision = "On"
}

resource "azurerm_security_center_workspace" "la_workspace" {
  scope        = data.azurerm_subscription.current.id
  workspace_id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${azurerm_log_analytics_workspace.workspace.resource_group_name}/providers/Microsoft.OperationalInsights/workspaces/${azurerm_log_analytics_workspace.workspace.name}"
}

resource "azapi_resource" "DfSMDVMSettings" {
  type      = "Microsoft.Security/serverVulnerabilityAssessmentsSettings@2022-01-01-preview"
  name      = "AzureServersSetting"
  parent_id = data.azurerm_subscription.current.id
  body = jsonencode({
    properties = {
      selectedProvider = "MdeTvm"
    }
    kind = "AzureServersSetting"
  })
  schema_validation_enabled = false
}

resource "azurerm_subscription_policy_assignment" "va-auto-provisioning" {
  name                 = "mdc-va-autoprovisioning"
  display_name         = "Configure machines to receive a vulnerability assessment provider"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/13ce0167-8ca6-4048-8e6b-f996402e3c1b"
  subscription_id      = data.azurerm_subscription.current.id
  identity {
    type = "SystemAssigned"
  }
  location   = var.location
  parameters = <<PARAMS
{ "vaType": { "value": "default" } }
PARAMS
}

resource "azurerm_role_assignment" "va-auto-provisioning-identity-role" {
  scope              = data.azurerm_subscription.current.id
  role_definition_id = "/providers/Microsoft.Authorization/roleDefinitions/fb1c8493-542b-48eb-b624-b4c8fea62acd"
  principal_id       = azurerm_subscription_policy_assignment.va-auto-provisioning.identity[0].principal_id
}

resource "azurerm_security_center_automation" "la-exports" {
  name                = "ExportToWorkspace"
  location            = azurerm_resource_group.diag.location
  resource_group_name = azurerm_resource_group.diag.name

  action {
    type        = "loganalytics"
    resource_id = azurerm_log_analytics_workspace.workspace.id
  }

  source {
    event_source = "Alerts"
    rule_set {
      rule {
        property_path  = "Severity"
        operator       = "Equals"
        expected_value = "High"
        property_type  = "String"
      }
      rule {
        property_path  = "Severity"
        operator       = "Equals"
        expected_value = "Medium"
        property_type  = "String"
      }
    }
  }

  source {
    event_source = "SecureScores"
  }

  source {
    event_source = "SecureScoreControls"
  }

  scopes = [data.azurerm_subscription.current.id]
}
