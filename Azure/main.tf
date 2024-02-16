resource "azurerm_resource_group" "default" {
  name     = lower("${random_pet.name_prefix.id}-${local.environment}") # Uses the generated random name for the resource group.
  location = var.location                                               # The location for the resource group.
}

# Generates a random password for use with the PostgreSQL server, enhancing security by avoiding hardcoded or weak passwords.
resource "random_password" "pass" {
  length           = 20
  special          = true
  override_special = "!#%+:=?@"
}

# Lock the resource group
/*resource "azurerm_management_lock" "rg_lock" {
  name       = "CanNotDelete"
  scope      = azurerm_resource_group.default.id
  lock_level = "CanNotDelete"
  notes      = "This resource group can not be deleted - lock set by Terraform"
  depends_on = [
    azurerm_virtual_network.default,
    azurerm_network_security_group.default,
    azurerm_subnet.default,
    azurerm_log_analytics_workspace.workspace,
    azurerm_log_analytics_solution.workspace_solution,
  
  ]
}
*/
