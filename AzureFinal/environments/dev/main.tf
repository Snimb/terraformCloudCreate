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
  psql_admin_login             = var.psql_admin_login
  psql_version                 = var.psql_version
  psql_storage_mb              = var.psql_storage_mb
  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled
  auto_grow_enabled            = var.auto_grow_enabled
  zone                         = var.zone
  maintenance_window           = var.maintenance_window
  # high_availability_mode       = var.high_availability_mode
  postgresql_configurations = var.postgresql_configurations
  database_names            = var.database_names
  total_memory_mb           = var.total_memory_mb
  cpu_cores                 = var.cpu_cores
  psql_subnet_name          = var.psql_subnet_name
  psql_address_prefixes     = var.psql_address_prefixes
  private_dns_zone_name     = var.private_dns_zone_name
  sp-tenant-id              = var.sp-tenant-id
  module_vnet_id            = module.vnetwork_dev.vnet_id
  module_vnet_name          = module.vnetwork_dev.vnet_name
  module_nsg_id             = module.vnetwork_dev.nsg_id
  module_vnet               = module.vnetwork_dev.vnet
  module_vnet_resource_grp  = module.vnetwork_dev.resource_group_name
}

/*
module "keyvault" {
  source   = "../../modules/keyvault"
  location = var.location
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_template_deployment = var.enabled_for_template_deployment
  enable_rbac_authorization       = var.enable_rbac_authorization
  purge_protection_enabled        = var.purge_protection_enabled
  soft_delete_retention_days      = var.soft_delete_retention_days
}

module "monitoring" {
  source                       = "../../modules/monitoring"
  location                     = var.location
  log_analytics_retention_days = var.log_analytics_retention_days
}

module "virtualmachines_dev" {
  source                 = "../../modules/virtualmachines"
  location               = var.location
  vm_size                = "Standard_DS1_v2"
  storage_account_type   = var.storage_account_type
  image_publisher        = var.image_publisher
  admin_ssh_key_username = var.admin_ssh_key_username
  image_sku              = var.image_sku
  vm_admin_username      = var.vm_admin_username
  image_offer            = var.image_offer
  admin_public_key_path  = var.admin_public_key_path
}
*/
