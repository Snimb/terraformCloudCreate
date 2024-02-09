# Creates a virtual network with a predefined address space. This network will contain all other network-related resources.
resource "azurerm_virtual_network" "default" {
  name                = "${random_pet.name_prefix.id}-vnet"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  address_space       = ["10.0.0.0/16"]
}

# Defines a network security group with a generic rule to allow all inbound TCP traffic. Adjust the rules based on your security requirements.
resource "azurerm_network_security_group" "default" {
  name                = "${random_pet.name_prefix.id}-nsg"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Creates a subnet within the virtual network. This subnet includes a delegation for Azure PostgreSQL Flexible Servers, enabling them to be associated with this subnet.
resource "azurerm_subnet" "default" {
  name                                      = "${random_pet.name_prefix.id}-subnet"
  virtual_network_name                      = azurerm_virtual_network.default.name
  resource_group_name                       = azurerm_resource_group.default.name
  address_prefixes                          = ["10.0.2.0/24"]
  private_endpoint_network_policies_enabled = false
  service_endpoints                         = ["Microsoft.Storage"]

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
}

# Associates the previously defined network security group with the subnet. This applies the security group's rules to the subnet.
resource "azurerm_subnet_network_security_group_association" "default" {
  subnet_id                 = azurerm_subnet.default.id
  network_security_group_id = azurerm_network_security_group.default.id
}

# Establishes a private DNS zone for the PostgreSQL server, ensuring it can be resolved within the virtual network.
resource "azurerm_private_dns_zone" "default" {
  name                = "${random_pet.name_prefix.id}-pdz.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.default.name

  depends_on = [azurerm_subnet_network_security_group_association.default]
}

# Links the private DNS zone with the virtual network, enabling name resolution within the network.
resource "azurerm_private_dns_zone_virtual_network_link" "default" {
  name                  = "${random_pet.name_prefix.id}-pdzvnetlink.com"
  private_dns_zone_name = azurerm_private_dns_zone.default.name
  virtual_network_id    = azurerm_virtual_network.default.id
  resource_group_name   = azurerm_resource_group.default.name
}