# Creates a subnet within the virtual network. This subnet includes a delegation for Azure PostgreSQL Flexible Servers, enabling them to be associated with this subnet.
resource "azurerm_subnet" "psql" {
  name                                          = lower("${var.subnet_prefix}-${random_pet.name_prefix.id}-${var.psql_subnet_name}")
  resource_group_name                           = var.module_vnet_resource_grp
  virtual_network_name                          = var.module_vnet_name
  address_prefixes                              = var.psql_address_prefixes
  private_endpoint_network_policies             = false
  private_link_service_network_policies_enabled = false
  service_endpoints                             = ["Microsoft.Storage", "Microsoft.KeyVault"]

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
    var.module_vnet
  ]
}

# Associates the previously defined network security group with the subnet. This applies the security group's rules to the subnet.
resource "azurerm_subnet_network_security_group_association" "psql" {
  subnet_id                 = azurerm_subnet.psql.id
  network_security_group_id = azurerm_network_security_group.psql.id
}

# Establishes a private DNS zone for the PostgreSQL server, ensuring it can be resolved within the virtual network.
resource "azurerm_private_dns_zone" "psql" {
  name                = lower("${var.pdz_prefix}-${var.private_dns_zone_name}.postgres.database.azure.com")
  resource_group_name = var.module_vnet_resource_grp

  depends_on = [azurerm_subnet_network_security_group_association.psql]
}

# Links the private DNS zone with the virtual network, enabling name resolution within the network.
resource "azurerm_private_dns_zone_virtual_network_link" "psql" {
  name                  = "${var.pdz_prefix}-${var.private_dns_zone_name}-pdzvnetlink.com"
  private_dns_zone_name = azurerm_private_dns_zone.psql.name
  virtual_network_id    = var.module_vnet_id
  resource_group_name   = var.module_vnet_resource_grp
}

# Defines a network security group.
resource "azurerm_network_security_group" "psql" {
  name                = lower("${var.nsg_prefix}-${random_pet.name_prefix.id}-${var.psql_nsg_name}-${local.environment}")
  location            = var.location
  resource_group_name = var.module_vnet_resource_grp

  dynamic "security_rule" {
    for_each = var.nsg_security_rules_psql
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
