# Resource group:
output "resource_group_name" {
  value = azurerm_resource_group.db.name # Outputs the name of the created resource group.
}

output "subnet_psql_id" {
  description = "Specifies the resource id of the psql subnets"
  value       = azurerm_subnet.psql.id
}

output "azurerm_postgresql_flexible_server_name" {
  value = azurerm_postgresql_flexible_server.psql.name # Outputs the name of the created PostgreSQL Flexible Server.
}

output "azurerm_postgresql_flexible_server" {
  value = azurerm_postgresql_flexible_server.psql 
}

# This password may be needed for administrative access or configuration changes to the database.
output "postgresql_flexible_server_admin_password" {
  sensitive = true                                                              # Marked as sensitive to prevent it from being displayed in logs or console output, ensuring security
  value     = azurerm_postgresql_flexible_server.psql.administrator_password # Output the admin password for the PostgreSQL Flexible Server
}

output "postgresql_flexible_server_admin_login" {
  value     = azurerm_postgresql_flexible_server.psql.administrator_login
}

output "azurerm_postgresql_flexible_server_id" {
  value = azurerm_postgresql_flexible_server.psql.id 
  }

output "specific_postgresql_flexible_server_database_names" {
  description = "List of names for the PostgreSQL databases."
  value = [for db in azurerm_postgresql_flexible_server_database.psqldb : db.name]
}

output "specific_postgresql_flexible_server_database_object" {
  description = "A map of all PostgreSQL database objects created."
  value = { for db in azurerm_postgresql_flexible_server_database.psqldb : db.name => {
    name      = db.name
    charset   = db.charset
    collation = db.collation
  }}
}

output "specific_postgresql_flexible_server_database_id" {
  value = { for k, db in azurerm_postgresql_flexible_server_database.psqldb : k => db.id }
}

output "private_dns_zone_id" {
  value = azurerm_private_dns_zone.psql.id
}

output "private_dns_zone_virtual_network_link_id" {
  value = azurerm_private_dns_zone_virtual_network_link.psql.id
}

output "postgresql_flexible_server_databases" {
  value = azurerm_postgresql_flexible_server_database.psqldb
}

output "psql_admin_password" {
  description = "The generated random password for PostgreSQL admin"
  value       = random_password.psql_admin_password.result
  sensitive   = true
}

output "account_id" {
  value = data.azurerm_client_config.current.client_id
}

output "psql_nsg_id" {
  value = azurerm_network_security_group.psql.id
  description = "The ID of the PostgreSQL Network Security Group"
}

output "psql_configurations" {
  value = var.postgresql_configurations
}
