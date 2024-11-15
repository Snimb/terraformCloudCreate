locals {
  service_delegation_actions = [
    "Microsoft.Network/virtualNetworks/subnets/join/action",
    "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
    "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
  ]
}

# Virutal network
resource "azurerm_virtual_network" "vnet" {
  name                = lower("${var.vnet_prefix}-${random_pet.name_prefix.id}-${var.vnet_name}-${local.environment}")
  address_space       = var.vnet_address_space
  resource_group_name = azurerm_resource_group.vnet.name
  location            = azurerm_resource_group.vnet.location

  depends_on = [
    azurerm_resource_group.vnet,
  ]
}

resource "azurerm_network_security_group" "secgr" {
  name                = lower("${var.nsg_prefix}-${random_pet.name_prefix.id}-${var.private_nsg_name}-${local.environment}")
  location            = azurerm_resource_group.vnet.location
  resource_group_name = azurerm_resource_group.vnet.name

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

resource "azurerm_private_dns_zone" "dns_auth_front" {
  name                = "privatelink.azuredatabricks.net"
  resource_group_name = azurerm_resource_group.vnet.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "transitdnszonevnetlink" {
  name                  = "dpcpspokevnetconnection"
  resource_group_name   = azurerm_virtual_network.vnet.name
  private_dns_zone_name = azurerm_private_dns_zone.dns_auth_front.name
  virtual_network_id    = azurerm_virtual_network.transit_vnet.id
}

resource "azurerm_route_table" "rtable" {
  name                = "${var.route_table}-${local.environment}"
  location            = azurerm_resource_group.vnet.location
  resource_group_name = azurerm_resource_group.vnet.name
}

# Subnet private
resource "azurerm_subnet" "private" {
  name                 = "private-${var.subnet_prefix}-${local.environment}"
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes = var.private_subnet_address_prefix

  delegation {
    name = "databricks-private-subnet-delegation"

    service_delegation {
      name    = "Microsoft.Databricks/workspaces"
      actions = local.service_delegation_actions
    }
  }
}

# Subnet public
resource "azurerm_subnet" "public" {
  name                 = "public-${var.subnet_prefix}-${local.environment}"
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes = var.public_subnet_address_prefix

  delegation {
    name = "databricks-public-subnet-delegation"

    service_delegation {
      name    = "Microsoft.Databricks/workspaces"
      actions = local.service_delegation_actions
    }
  }
}

# Associates the previously defined network security group with the subnet. This applies the security group's rules to the subnet.
resource "azurerm_subnet_network_security_group_association" "private" {
  subnet_id                 = azurerm_subnet.private.id
  network_security_group_id = azurerm_network_security_group.secgr.id
}

resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = azurerm_network_security_group.secgr.id
}

resource "azurerm_subnet_route_table_association" "private" {
  subnet_id      = azurerm_subnet.private.id
  route_table_id = azurerm_route_table.rtable.id
}

resource "azurerm_subnet_route_table_association" "public" {
  subnet_id      = azurerm_subnet.public.id
  route_table_id = azurerm_route_table.rtable.id
}

