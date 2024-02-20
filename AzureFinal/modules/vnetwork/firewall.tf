### Firewall ###
/*resource "azurerm_firewall" "default" {
  name                = lower("${random_pet.name_prefix.id}-azurefirewall")
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }
}
*/