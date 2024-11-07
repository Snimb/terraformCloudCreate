resource "azurerm_storage_account" "dls" {
  count                    = length(var.storage_account_names)
  name                     = "dls-${var.storage_account_names[count.index]}-${local.environment}"
  location                 = var.location
  resource_group_name      = azurerm_resource_group.lakehouse.name
  account_tier             = "Standard"
  account_replication_type = "GRS"
  is_hns_enabled           = true
}