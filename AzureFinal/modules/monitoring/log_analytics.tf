# Create Log Analytics Workspace 
resource "azurerm_log_analytics_workspace" "workspace" {
  name                = lower("${var.log_analytics_workspace_prefix}-${random_pet.name_prefix.id}-${var.log_analytics_workspace_name}-${local.environment}")
  resource_group_name = azurerm_resource_group.diag.name
  location            = var.location
  sku                 = var.log_analytics_workspace_sku
  retention_in_days   = var.log_analytics_retention_days

  depends_on = [
    azurerm_resource_group.diag,
  ]
}

# Create log analytics workspace solution
resource "azurerm_log_analytics_solution" "workspace_solution" {
  for_each              = var.solution_plan_map
  solution_name         = each.key
  resource_group_name   = azurerm_resource_group.diag.name
  location              = var.location
  workspace_resource_id = azurerm_log_analytics_workspace.workspace.id
  workspace_name        = azurerm_log_analytics_workspace.workspace.name
  plan {
    product   = each.value.product
    publisher = each.value.publisher
  }
  depends_on = [
    azurerm_log_analytics_workspace.workspace,
  ]
}
