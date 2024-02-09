# Create the resource group
/*resource "azurerm_resource_group" "workspace" {
  name     = lower("${var.rg_prefix}-${var.log_analytics_workspace_rg_name}-${local.environment}")
  location = var.log_analytics_workspace_location
  tags     = merge(local.default_tags, var.log_analytics_tags)
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

# Create Log Analytics Workspace 
resource "azurerm_log_analytics_workspace" "workspace" {
  name                = lower("${var.log_analytics_workspace_prefix}-${var.log_analytics_workspace_name}-${local.environment}")
  resource_group_name = azurerm_resource_group.workspace.name
  location            = var.log_analytics_workspace_location
  sku                 = var.log_analytics_workspace_sku
  retention_in_days   = var.log_analytics_retention_days != "" ? var.log_analytics_retention_days : null
  tags                = merge(local.default_tags, var.log_analytics_tags)
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
  depends_on = [
    azurerm_resource_group.workspace,
  ]
}

# Create log analytics workspace solution
resource "azurerm_log_analytics_solution" "workspace_solution" {
  for_each              = var.solution_plan_map
  solution_name         = each.key
  resource_group_name   = azurerm_resource_group.workspace.name
  location              = var.log_analytics_workspace_location
  workspace_resource_id = azurerm_log_analytics_workspace.workspace.id
  workspace_name        = azurerm_log_analytics_workspace.workspace.name
  plan {
    product   = each.value.product
    publisher = each.value.publisher
  }
  tags = merge(local.default_tags, var.log_analytics_tags)
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
  depends_on = [
    azurerm_log_analytics_workspace.workspace,
  ]
}

# Lock the resource group
resource "azurerm_management_lock" "rg_workspace_lock" {
  name       = "CanNotDelete"
  scope      = azurerm_resource_group.workspace.id
  lock_level = "CanNotDelete"
  notes      = "This resource group can not be deleted - lock set by Terraform"
  depends_on = [
    azurerm_resource_group.workspace,
    azurerm_log_analytics_workspace.workspace,
    azurerm_log_analytics_solution.workspace_solution,
  ]
}
*/