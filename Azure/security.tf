### Public IP ###
resource "azurerm_public_ip" "bastion_public_ip" {
  name                = lower("${random_pet.name_prefix.id}-bastion-ip")
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

### Bastion ###
resource "azurerm_bastion_host" "azure_bastion" {
  name                = lower("${random_pet.name_prefix.id}-bastion")
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.hub_bastion.id
    public_ip_address_id = azurerm_public_ip.bastion_public_ip.id
  }
}

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