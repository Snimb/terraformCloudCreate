output "resource_group_name" {
  value = azurerm_resource_group.default.name # Outputs the name of the created resource group.
}

output "azurerm_postgresql_flexible_server" {
  value = azurerm_postgresql_flexible_server.default.name # Outputs the name of the created PostgreSQL Flexible Server.
}

# This allows you to easily retrieve and use the database name in other parts of your infrastructure or in external tools.
output "postgresql_flexible_server_database_name" {
  value = azurerm_postgresql_flexible_server_database.default.name # Output the name of the PostgreSQL Flexible Server Database
}


# This password may be needed for administrative access or configuration changes to the database.
output "postgresql_flexible_server_admin_password" {
  sensitive = true                                                              # Marked as sensitive to prevent it from being displayed in logs or console output, ensuring security
  value     = azurerm_postgresql_flexible_server.default.administrator_password # Output the admin password for the PostgreSQL Flexible Server
}