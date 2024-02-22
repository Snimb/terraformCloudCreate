module "vnetwork_dev" {
  source                              = "../../modules/vnetwork"
  location                            = var.location
  vnet_address_space                  = var.vnet_address_space
  jumpbox_subnet_address_prefix       = var.jumpbox_subnet_address_prefix
  hub_bastion_subnet_address_prefixes = var.hub_bastion_subnet_address_prefixes
  nsg_security_rules                  = var.nsg_security_rules
}

module "database" {
  source                       = "../../modules/database"
  location                     = var.location
  psql_sku_name                = var.psql_sku_name
  psql_version                 = var.psql_version
  psql_storage_mb              = var.psql_storage_mb
  backup_retention_days        = var.backup_retention_days
  psql_address_prefixes        = var.psql_address_prefixes
  zone                         = var.zone
  sp-tenant-id                 = var.sp-tenant-id
  database_names               = var.database_names
  total_memory_mb              = var.total_memory_mb
  cpu_cores                    = var.cpu_cores
  psql_admin_login             = var.psql_admin_login
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled
  auto_grow_enabled            = var.auto_grow_enabled
  maintenance_window           = var.maintenance_window
  # high_availability_mode       = var.high_availability_mode
  postgresql_configurations = var.postgresql_configurations
  psql_subnet_name          = var.psql_subnet_name
  private_dns_zone_name     = var.private_dns_zone_name
  module_vnet_id            = module.vnetwork_dev.vnet_id
  module_vnet_name          = module.vnetwork_dev.vnet_name
  module_nsg_id             = module.vnetwork_dev.nsg_id
  module_vnet               = module.vnetwork_dev.vnet
  module_vnet_resource_grp  = module.vnetwork_dev.resource_group_name
}

module "keyvault" {
  source                            = "../../modules/keyvault"
  location                          = var.location
  enabled_for_disk_encryption       = var.enabled_for_disk_encryption
  enabled_for_deployment            = var.enabled_for_deployment
  enabled_for_template_deployment   = var.enabled_for_template_deployment
  enable_rbac_authorization         = var.enable_rbac_authorization
  purge_protection_enabled          = var.purge_protection_enabled
  soft_delete_retention_days        = var.soft_delete_retention_days
  module_postgres_fs                = module.database.azurerm_postgresql_flexible_server
  module_postgres_fs_name           = module.database.azurerm_postgresql_flexible_server_name
  module_postgres_fs_database       = module.database.specific_postgresql_flexible_server_database_object
  module_postgres_fs_database_names = module.database.specific_postgresql_flexible_server_database_names
  module_postgres_password          = module.database.psql_admin_password
  module_postgres_admin_login       = module.database.postgresql_flexible_server_admin_login
  module_postgres_admin_pass        = module.database.postgresql_flexible_server_admin_password
  module_vnet_id                    = module.vnetwork_dev.vnet_id
  module_vnet_name                  = module.vnetwork_dev.vnet_name
  module_vnet                       = module.vnetwork_dev.vnet
  module_vnet_resource_grp          = module.vnetwork_dev.resource_group_name
  module_subnet_jumpbox_id          = module.vnetwork_dev.subnet_jumpbox_id
  kv_certificate_permissions_full   = var.kv_certificate_permissions_full
  kv_default_action                 = var.kv_default_action
  kv_ip_rules                       = var.kv_ip_rules
  kv_key_permissions_full           = var.kv_key_permissions_full
  kv_secret_permissions_full        = var.kv_secret_permissions_full
  kv_storage_permissions_full       = var.kv_storage_permissions_full
  kv_virtual_network_subnet_ids     = var.kv_virtual_network_subnet_ids
  kv_sku_name                       = var.kv_sku_name
  bypass                            = var.bypass

}


module "monitoring" {
  source                       = "../../modules/monitoring"
  location                     = var.location
  log_analytics_retention_days = var.log_analytics_retention_days
  solution_plan_map            = var.solution_plan_map
  log_analytics_workspace_sku  = var.log_analytics_workspace_sku
  module_vnet                  = module.vnetwork_dev.vnet
  module_vnet_id               = module.vnetwork_dev.vnet_id
  module_postgres_fs_id        = module.database.azurerm_postgresql_flexible_server_id
  module_postgres_fs_name      = module.database.azurerm_postgresql_flexible_server_name
  module_postgres_fs           = module.database.azurerm_postgresql_flexible_server
  module_keyvault              = module.keyvault.key_vault_object
  module_keyvault_id           = module.keyvault.key_vault_id
  module_keyvault_name         = module.keyvault.key_vault_name
}


module "virtualmachines_dev" {
  source                   = "../../modules/virtualmachines"
  location                 = var.location
  vm_size                  = "Standard_DS1_v2"
  storage_account_type     = var.storage_account_type
  image_publisher          = var.image_publisher
  admin_ssh_key_username   = var.admin_ssh_key_username
  image_sku                = var.image_sku
  vm_admin_username        = var.vm_admin_username
  image_offer              = var.image_offer
  admin_public_key_path    = var.admin_public_key_path
  image_version            = var.image_version
  os_disk_caching          = var.os_disk_caching
  module_jumpbox_subnet_id = module.vnetwork_dev.subnet_jumpbox_id
  module_keyvault_name     = module.keyvault.key_vault_name
  # module_user_assigned_identity_id        = module.keyvault.user_assigned_identity_id
  # module_user_assigned_identity_client_id = module.keyvault.user_assigned_identity_client_id
  module_secret_connection_string_names = module.keyvault.db_connection_strings_secret_names
  module_keyvault_id                    = module.keyvault.key_vault_id
}

