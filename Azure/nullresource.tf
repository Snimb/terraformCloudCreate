/*
# Utilizes a null resource to run a local script after the PostgreSQL server is provisioned. This script can configure the database or perform initial setup tasks.
resource "null_resource" "db_init" {
  depends_on = [azurerm_postgresql_flexible_server.default]

  provisioner "local-exec" {
    command = "bash ${path.module}/auto-edit-db-configs.sh '${azurerm_postgresql_flexible_server.default.fqdn}' '${random_password.pass.result}' '${azurerm_postgresql_flexible_server_database.default.name}' '${azurerm_postgresql_flexible_server.default.administrator_login}"
  }
}
*/