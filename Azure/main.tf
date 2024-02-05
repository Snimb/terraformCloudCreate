resource "azurerm_resource_group" "free_tier_resources" {
  name     = "free-tier-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "free_tier_vnet" {
  name                = "free-tier-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.free_tier_resources.location
  resource_group_name = azurerm_resource_group.free_tier_resources.name
}

resource "azurerm_subnet" "free_tier_subnet" {
  name                 = "free-tier-subnet"
  resource_group_name  = azurerm_resource_group.free_tier_resources.name
  virtual_network_name = azurerm_virtual_network.free_tier_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
}

resource "azurerm_private_dns_zone" "free_tier_dns_zone" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.free_tier_resources.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "free_tier_dns_vnet_link" {
  name                  = "free-tier-vnet-link"
  resource_group_name   = azurerm_resource_group.free_tier_resources.name
  private_dns_zone_name = azurerm_private_dns_zone.free_tier_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.free_tier_vnet.id
}

resource "azurerm_postgresql_flexible_server" "free_tier_postgresql_flexible_server" {
  name                         = "750h-free-psqlflexible"
  resource_group_name          = azurerm_resource_group.free_tier_resources.name
  location                     = azurerm_resource_group.free_tier_resources.location
  version                      = "16"
  administrator_login          = "postgres"
  administrator_password       = "P4ssw0rd!"
  sku_name                     = "B_Standard_B1ms" # Smallest size in Burstable tier
  storage_mb                   = 32768
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = false
  delegated_subnet_id = azurerm_subnet.free_tier_subnet.id
  private_dns_zone_id = azurerm_private_dns_zone.free_tier_dns_zone.id
}

resource "null_resource" "db_init" {
  depends_on = [azurerm_postgresql_flexible_server.free_tier_postgresql_flexible_server]

  provisioner "local-exec" {
    command = "bash ${path.module}/auto-edit-configs.sh"
  }
}
