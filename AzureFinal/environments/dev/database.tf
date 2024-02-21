module "database" {
  source                = "../../modules/database"
  location              = module.vnetwork.location
  cpu_cores             = ""
  backup_retention_days = ""
  database_names        = [""]
  zone                  = ""
  psql_address_prefixes = [""]
  psql_admin_login      = ""
  psql_sku_name         = ""
  psql_version          = ""
  psql_storage_mb       = ""
  total_memory_mb       = ""
}
