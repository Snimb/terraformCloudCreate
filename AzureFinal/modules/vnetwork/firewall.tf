### Firewall ###
/*
# Public IP:
resource "azurerm_public_ip" "firewall_public_ip" {
  name                = lower("${var.firewall_name}-${random_pet.name_prefix.id}-public-ip")
  location            = azurerm_resource_group.vnet.location
  resource_group_name = azurerm_resource_group.vnet.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "default" {
  name                = lower("${random_pet.name_prefix.id}-azurefirewall")
  location            = azurerm_resource_group.vnet.location
  resource_group_name = azurerm_resource_group.vnet.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.firewall_public_ip.id
  }
}
*/