/*
resource "azurerm_private_endpoint" "default" {
  # Defines the name of the private endpoint, dynamically incorporating the prefix from `random_pet`.
  name = "${random_pet.name_prefix.id}-endpoint"

  # Specifies the location and resource group from the existing `azurerm_resource_group` resource.
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  # Associates the private endpoint with a specific subnet within a Virtual Network.
  subnet_id = azurerm_subnet.default.id


  # Configures the connection to a specific service, in this case, the PostgreSQL Flexible Server.
  private_service_connection {
    # Unique name for the private service connection.
    name = "${random_pet.name_prefix.id}-privateserviceconnection"

    # The ID of the Azure PostgreSQL Flexible Server to which the private endpoint connects.
    private_connection_resource_id = azurerm_postgresql_flexible_server.default.id

    subresource_names = ["postgresqlServer"]
    # Automatically approves the connection without manual intervention.
    is_manual_connection = false

  }

  # Groups related private DNS zones to the private endpoint for name resolution within the VNet.
  private_dns_zone_group {
    # Names the DNS zone group, incorporating the dynamic prefix.
    name = "${random_pet.name_prefix.id}-dns-zone-group"

    # Specifies the ID(s) of the private DNS zone(s) associated with this endpoint.
    private_dns_zone_ids = [azurerm_private_dns_zone.default.id]
  }
}
*/