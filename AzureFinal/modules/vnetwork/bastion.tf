# Public IP:
resource "azurerm_public_ip" "bastion_public_ip" {
  name                = lower("${var.bastion_name}-${random_pet.name_prefix.id}-public-ip")
  location            = azurerm_resource_group.vnet.location
  resource_group_name = azurerm_resource_group.vnet.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Bastion:
resource "azurerm_bastion_host" "azure_bastion" {
  name                = lower("${var.bastion_name}-${random_pet.name_prefix.id}-${local.environment}")
  location            = azurerm_resource_group.vnet.location
  resource_group_name = azurerm_resource_group.vnet.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.hub_bastion.id
    public_ip_address_id = azurerm_public_ip.bastion_public_ip.id
  }
}