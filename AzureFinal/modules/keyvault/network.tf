# Create private DNS zone for key vault
resource "azurerm_private_dns_zone" "pdz_kv" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.module_vnet_resource_grp

  depends_on = [
    var.module_vnet_id
  ]
}

# Create private virtual network link to spoke vnet
resource "azurerm_private_dns_zone_virtual_network_link" "kv_pdz_vnet_link" {
  name                  = "privatelink_to_${var.module_vnet_name}"
  resource_group_name   = var.module_vnet_resource_grp
  virtual_network_id    = var.module_vnet_id
  private_dns_zone_name = azurerm_private_dns_zone.pdz_kv.name

  depends_on = [
    var.module_vnet_resource_grp,
    var.module_vnet_id,
    azurerm_private_dns_zone.pdz_kv
  ]
}

# Create private endpoint for key vault
resource "azurerm_private_endpoint" "pe_kv" {
  name                = lower("${var.private_endpoint_prefix}-${azurerm_key_vault.kv.name}")
  location            = azurerm_key_vault.kv.location
  resource_group_name = azurerm_key_vault.kv.resource_group_name
  subnet_id           = var.module_subnet_jumpbox_id

  private_service_connection {
    name                           = "pe-${azurerm_key_vault.kv.name}"
    private_connection_resource_id = azurerm_key_vault.kv.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default" 
    private_dns_zone_ids = [azurerm_private_dns_zone.pdz_kv.id]
  }

  depends_on = [
    azurerm_key_vault.kv,
    azurerm_private_dns_zone.pdz_kv
  ]
}