resource "azurerm_databricks_workspace" "example" {
  name                = "databricks-workspace"
  resource_group_name = azurerm_resource_group.vnet.name
  location            = azurerm_resource_group.vnet.location
  sku                 = var.databricks_ws_sku

  # Assigning virtual network and subnets for secure cluster connectivity
  custom_parameters {
    virtual_network_id  = azurerm_virtual_network.vnet.id
    public_subnet_name  = azurerm_subnet.public.name
    private_subnet_name = azurerm_subnet.private.name
    # Attach to existing storage account for DBFS (Databricks File System)
    storage_account_name     = azurerm_storage_account.dls.name
    storage_account_sku_name = azurerm_storage_account.dls.account_tier

  }

  # Customer Managed Key Encryption
  customer_managed_key_enabled = false
  #managed_services_cmk_key_vault_id = azurerm_key_vault.example.id
  #managed_services_cmk_key_vault_key_id = azurerm_key_vault_key.example.id

  # Enable public network access only if necessary for workspace UI
  public_network_access_enabled = false

  # Set managed resource group for Databricks resources
  managed_resource_group_name = "databricks-managed-resources"
}
