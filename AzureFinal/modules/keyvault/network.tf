# Create private DNS zone for key vault
resource "azurerm_private_dns_zone" "pdz_kv" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_virtual_network.vnet.resource_group_name

  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

# Create private virtual network link to spoke vnet
resource "azurerm_private_dns_zone_virtual_network_link" "kv_pdz_vnet_link" {
  name                  = "privatelink_to_${azurerm_virtual_network.vnet.name}"
  resource_group_name   = azurerm_resource_group.vnet.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  private_dns_zone_name = azurerm_private_dns_zone.pdz_kv.name

  depends_on = [
    azurerm_resource_group.vnet,
    azurerm_virtual_network.vnet,
    azurerm_private_dns_zone.pdz_kv
  ]
}

# Create private endpoint for key vault
resource "azurerm_private_endpoint" "pe_kv" {
  name                = lower("${var.private_endpoint_prefix}-${azurerm_key_vault.kv.name}")
  location            = azurerm_key_vault.kv.location
  resource_group_name = azurerm_key_vault.kv.resource_group_name
  subnet_id           = azurerm_subnet.jumpbox.id

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