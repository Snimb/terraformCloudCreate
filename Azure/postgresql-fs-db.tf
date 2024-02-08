resource "azurerm_postgresql_flexible_server_database" "default" {
  name      = "${random_pet.name_prefix.id}-db"             # The name of the database, prefixed with the generated name to ensure uniqueness.
  server_id = azurerm_postgresql_flexible_server.default.id # Links the database to the created PostgreSQL server.
  collation = "en_US.utf8"                                  # Sets the database collation.
  charset   = "UTF8"                                        # Sets the database character set.

  # prevent the possibility of accidental data loss
  /*lifecycle {
    prevent_destroy = true
  }*/
}
