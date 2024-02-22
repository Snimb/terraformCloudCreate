# Create Azure Key Vault using terraform
resource "azurerm_key_vault" "kv" {
  name                            = lower("${var.kv_prefix}-${var.kv_name}-${local.environment}")
  resource_group_name             = azurerm_resource_group.kv.name
  location                        = azurerm_resource_group.kv.location
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
    azurerm_resource_group.kv,
    data.azurerm_client_config.current
  ]
}

# Create key vault secret for postgres database password
resource "azurerm_key_vault_secret" "postgres_password" {
  name         = "postgres-db-password"
  value        = var.module_postgres_password
  key_vault_id = azurerm_key_vault.kv.id
  tags         = {}

  depends_on = [
    azurerm_key_vault.kv,
  ]
}

# Create key vault secret for postgres database hostname
resource "azurerm_key_vault_secret" "postgres_hostname" {
  name         = "postgres-db-hostname"
  value        = "${var.module_postgres_fs_name}.postgres.database.azure.com"
  key_vault_id = azurerm_key_vault.kv.id
  tags         = {}

  depends_on = [
    azurerm_key_vault.kv,
  ]
}

# Create key vault secret for database1-connection-string
resource "azurerm_key_vault_secret" "db_connection_strings" {
  for_each = var.module_postgres_fs_database

  name         = "db-connection-string-${each.key}"
  value        = "User ID=${var.module_postgres_admin_login};Password=${var.module_postgres_admin_pass};Host=${var.module_postgres_fs_name}.postgres.database.azure.com;database=${each.value.name};Port=5432;"
  key_vault_id = azurerm_key_vault.kv.id
  tags         = {}

  depends_on = [
    azurerm_key_vault.kv,
    var.module_postgres_fs,
    var.module_postgres_fs_database,
  ]
}

resource "azurerm_key_vault_access_policy" "vm" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.default.principal_id

  secret_permissions = var.kv_secret_permissions_full
}

resource "azurerm_user_assigned_identity" "default" {
  location            = azurerm_resource_group.kv.location
  name                = "default-user-identity"
  resource_group_name = azurerm_resource_group.kv.name
}
