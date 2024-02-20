# Virutal network
resource "azurerm_virtual_network" "vnet" {
  name                = lower("${var.vnet_prefix}-${var.vnet_name}-${local.environment}")
  address_space       = var.vnet_address_space
  resource_group_name = azurerm_resource_group.vnet.name
  location            = azurerm_resource_group.vnet.location
  depends_on = [
    azurerm_resource_group.vnet,
  ]
}

# jumpm VM server subnet
resource "azurerm_subnet" "jumpbox" {
  name                                          = lower("${var.subnet_prefix}-${var.jumpbox_subnet_name}")
  resource_group_name                           = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name                          = azurerm_virtual_network.vnet.name
  address_prefixes                              = var.jumpbox_subnet_address_prefix
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = false
  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

# Create hub bastion host subnet
resource "azurerm_subnet" "hub_bastion" {
  name                                          = var.hub_bastion_subnet_name
  resource_group_name                           = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name                          = azurerm_virtual_network.vnet.name
  address_prefixes                              = var.hub_bastion_subnet_address_prefixes
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = false
  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

# Defines a network security group with a generic rule to allow all inbound TCP traffic. Adjust the rules based on your security requirements.
resource "azurerm_network_security_group" "default" {
  name                = lower("${var.nsg_prefix}-${var.nsg_name}-${local.environment}")
  location            = azurerm_resource_group.db.location
  resource_group_name = azurerm_resource_group.db.name

  dynamic "security_rule" {
    for_each = var.nsg_security_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}