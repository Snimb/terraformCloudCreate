resource "azurerm_virtual_network" "hub_vnet" {
  name                = lower("${var.hub_vnet_name}-${random_pet.name_prefix.id}-${local.environment}")
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  address_space       = var.hub_vnet_address_space
  depends_on = [
    azurerm_resource_group.default
  ]
}

# Defines a network security group with a generic rule to allow all inbound TCP traffic. Adjust the rules based on your security requirements.
resource "azurerm_network_security_group" "default" {
  name                = lower("${var.nsg_prefix}-${random_pet.name_prefix.id}-${local.environment}")
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

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

# Creates a subnet within the virtual network. This subnet includes a delegation for Azure PostgreSQL Flexible Servers, enabling them to be associated with this subnet.
resource "azurerm_subnet" "psql" {
  name                                          = lower("${var.subnet_prefix}-${random_pet.name_prefix.id}-${var.psql_subnet_name}")
  resource_group_name                           = azurerm_resource_group.default.name
  virtual_network_name                          = azurerm_virtual_network.vnet.name
  address_prefixes                              = var.psql_address_prefixes
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = false
  service_endpoints                             = ["Microsoft.Storage"]

  # The delegation block allows the subnet to be dedicated for specific Azure services, in this case, Azure Database for PostgreSQL. 
  # This setup permits the PostgreSQL service to integrate deeply with the subnet, enhancing network security and performance by enabling direct service connections. 
  # Essentially, it delegates subnet management for database services, ensuring optimized configurations and maintenance by Azure.
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
  depends_on = [
    azurerm_virtual_network.vnet
  ]
}



# Associates the previously defined network security group with the subnet. This applies the security group's rules to the subnet.
resource "azurerm_subnet_network_security_group_association" "default" {
  subnet_id                 = azurerm_subnet.psql.id
  network_security_group_id = azurerm_network_security_group.default.id
}

# Establishes a private DNS zone for the PostgreSQL server, ensuring it can be resolved within the virtual network.
resource "azurerm_private_dns_zone" "default" {
  name                = lower("${random_pet.name_prefix.id}-${var.pdz_prefix}.postgres.database.azure.com")
  resource_group_name = azurerm_resource_group.default.name

  depends_on = [azurerm_subnet_network_security_group_association.default]
}

# Links the private DNS zone with the virtual network, enabling name resolution within the network.
resource "azurerm_private_dns_zone_virtual_network_link" "default" {
  name                  = "${random_pet.name_prefix.id}-pdzvnetlink.com"
  private_dns_zone_name = azurerm_private_dns_zone.default.name
  virtual_network_id    = azurerm_virtual_network.hub_vnet.id
  resource_group_name   = azurerm_resource_group.default.name
}


// jumpm VM server subnet
resource "azurerm_subnet" "jumpbox" {
  name                                          = lower("${var.subnet_prefix}-${random_pet.name_prefix.id}-${var.jumpbox_subnet_name}")
  resource_group_name                           = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name                          = azurerm_virtual_network.vnet.name
  address_prefixes                              = var.jumpbox_subnet_address_prefix
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = false
  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

//Create hub vnet gateway subnet
resource "azurerm_subnet" "hub_gateway" {
  name                 = var.hub_gateway_subnet_name
  resource_group_name  = azurerm_virtual_network.hub_vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = var.hub_gateway_subnet_address_prefixes
  depends_on = [
    azurerm_virtual_network.hub_vnet
  ]
}

// Create hub bastion host subnet
resource "azurerm_subnet" "hub_bastion" {
  name                                          = var.hub_bastion_subnet_name
  resource_group_name                           = azurerm_virtual_network.hub_vnet.resource_group_name
  virtual_network_name                          = azurerm_virtual_network.hub_vnet.name
  address_prefixes                              = var.hub_bastion_subnet_address_prefixes
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = false
  depends_on = [
    azurerm_virtual_network.hub_vnet
  ]
}

// Create hub application gateway subnet
resource "azurerm_subnet" "appgtw" {
  name                                          = lower("${var.subnet_prefix}-${random_pet.name_prefix.id}-${var.appgtw_subnet_name}")
  resource_group_name                           = azurerm_virtual_network.hub_vnet.resource_group_name
  virtual_network_name                          = azurerm_virtual_network.hub_vnet.name
  address_prefixes                              = var.appgtw_address_prefixes
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = false
  depends_on = [
    azurerm_virtual_network.hub_vnet
  ]
}

// Create hub azure firewall subnet
resource "azurerm_subnet" "firewall" {
  name                                          = var.hub_firewall_subnet_name
  resource_group_name                           = azurerm_virtual_network.hub_vnet.resource_group_name
  virtual_network_name                          = azurerm_virtual_network.hub_vnet.name
  address_prefixes                              = var.hub_firewall_subnet_address_prefixes
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = false
  depends_on = [
    azurerm_virtual_network.hub_vnet
  ]
}

# Create spoke virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = lower("${var.spoke_vnet_name}-${random_pet.name_prefix.id}-${local.environment}")
  address_space       = var.spoke_vnet_address_space
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  depends_on = [
    azurerm_resource_group.default,
  ]
}


// gateway subnet
resource "azurerm_subnet" "gateway" {
  name                 = "gateway"
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.gateway_address_prefixes
  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

// VPN gateway subnet
resource "azurerm_subnet" "vpn_gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.gatewaysubnet_address_prefixes
  depends_on = [
    azurerm_virtual_network.vnet
  ]
}
