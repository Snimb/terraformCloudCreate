# Create Azure Key Vault using terraform
resource "azurerm_key_vault" "kv" {
  name                            = lower("${var.kv_prefix}-${var.kv_name}-${local.environment}")
  resource_group_name             = azurerm_resource_group.db.name
  location                        = azurerm_resource_group.db.location
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = var.kv_sku_name
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_template_deployment = var.enabled_for_template_deployment
  enable_rbac_authorization       = var.enable_rbac_authorization
  purge_protection_enabled        = var.purge_protection_enabled
  soft_delete_retention_days      = var.soft_delete_retention_days

  timeouts {
    delete = "60m"
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    certificate_permissions = var.kv_certificate_permissions_full
    key_permissions         = var.kv_key_permissions_full
    secret_permissions      = var.kv_secret_permissions_full
    storage_permissions     = var.kv_storage_permissions_full
  }

  network_acls {
    default_action             = "Allow"
    bypass                     = "AzureServices"
    ip_rules                   = var.kv_ip_rules
    virtual_network_subnet_ids = var.kv_virtual_network_subnet_ids
  }

  depends_on = [
    azurerm_resource_group.db,
    data.azurerm_client_config.current
  ]
}

# Create private DNS zone for key vault
resource "azurerm_private_dns_zone" "pdz_kv" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_virtual_network.vnet.resource_group_name

  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

# Create private virtual network link to spoke vnet
resource "azurerm_private_dns_zone_virtual_network_link" "kv_pdz_vnet_link" {
  name                  = "privatelink_to_${azurerm_virtual_network.vnet.name}"
  resource_group_name   = azurerm_resource_group.vnet.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  private_dns_zone_name = azurerm_private_dns_zone.pdz_kv.name

  depends_on = [
    azurerm_resource_group.vnet,
    azurerm_virtual_network.vnet,
    azurerm_private_dns_zone.pdz_kv
  ]
}

# Create private endpoint for key vault
resource "azurerm_private_endpoint" "pe_kv" {
  name                = lower("${var.private_endpoint_prefix}-${azurerm_key_vault.kv.name}")
  location            = azurerm_key_vault.kv.location
  resource_group_name = azurerm_key_vault.kv.resource_group_name
  subnet_id           = azurerm_subnet.jumpbox.id

  private_service_connection {
    name                           = "pe-${azurerm_key_vault.kv.name}"
    private_connection_resource_id = azurerm_key_vault.kv.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default" 
    private_dns_zone_ids = [azurerm_private_dns_zone.pdz_kv.id]
  }

  depends_on = [
    azurerm_key_vault.kv,
    azurerm_private_dns_zone.pdz_kv
  ]
}

# generate random password for postgreSQL admin password
resource "random_password" "psql_admin_password" {
  length           = 20
  special          = true
  lower            = true
  upper            = true
  override_special = "!#$" //"!#$%&*()-_=+[]{}<>:?"
}

# Create key vault secret for postgres database password
resource "azurerm_key_vault_secret" "secret_1" {
  name         = "postgres-db-password"
  value        = random_password.psql_admin_password.result
  key_vault_id = azurerm_key_vault.kv.id
  tags         = {}

  depends_on = [
    azurerm_key_vault.kv,
  ]
}

# Create key vault secret for postgres database hostname
resource "azurerm_key_vault_secret" "secret_2" {
  name         = "postgres-db-hostname"
  value        = "${azurerm_postgresql_flexible_server.psql.name}.postgres.database.azure.com"
  key_vault_id = azurerm_key_vault.kv.id
  tags         = {}

  depends_on = [
    azurerm_key_vault.kv,
  ]
}

# Create key vault secret for database1-connection-string
resource "azurerm_key_vault_secret" "secret_3" {
  name         = "db-connection-string"
  value        = "User ID=${azurerm_postgresql_flexible_server.psql.administrator_login};Password=${azurerm_postgresql_flexible_server.psql.administrator_password};Host=${azurerm_postgresql_flexible_server.psql.name}.postgres.database.azure.com;database=${azurerm_postgresql_flexible_server_database.psqldb.name};Port=5432;"
  key_vault_id = azurerm_key_vault.kv.id
  tags         = {}

  depends_on = [
    azurerm_key_vault.kv,
    azurerm_postgresql_flexible_server.psql,
    azurerm_postgresql_flexible_server_database.psqldb
  ]
}

resource "azurerm_key_vault_access_policy" "vm" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.default.principal_id

  secret_permissions = var.kv_secret_permissions_full
}

resource "azurerm_user_assigned_identity" "default" {
  location            = azurerm_resource_group.db.location
  name                = "default-user-identity"
  resource_group_name = azurerm_resource_group.db.name
}
