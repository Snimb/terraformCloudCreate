# Apply recommended settings

# Enables specified PostgreSQL extensions on the Azure Flexible Server.
# Extensions like CITEXT for case-insensitive text data types, BTREE_GIST for GiST index operator classes,
resource "azurerm_postgresql_flexible_server_configuration" "azure_extensions" {
  name      = "azure.extensions"
  server_id = azurerm_postgresql_flexible_server.default.id
  value     = "CITEXT,BTREE_GIST"
}

# Configures the amount of memory PostgreSQL should use for shared memory buffers.
# This setting directly affects performance by determining how much data can be cached in memory.
resource "azurerm_postgresql_flexible_server_configuration" "shared_buffers" {
  name      = "shared_buffers"
  server_id = azurerm_postgresql_flexible_server.default.id
  value     = local.shared_buffers
}

# Sets the amount of memory to be used by internal sort operations and hash tables before writing to temporary disk files.
# Properly sizing this can improve query performance.
resource "azurerm_postgresql_flexible_server_configuration" "work_mem" {
  name      = "work_mem"
  server_id = azurerm_postgresql_flexible_server.default.id
  value     = local.work_mem
}

# Determines the amount of memory used for maintenance operations, such as VACUUM, CREATE INDEX, and ALTER TABLE ADD FOREIGN KEY.
resource "azurerm_postgresql_flexible_server_configuration" "maintenance_work_mem" {
  name      = "maintenance_work_mem"
  server_id = azurerm_postgresql_flexible_server.default.id
  value     = local.maintenance_work_mem
}

# Sets the planner's assumption about the effective size of the disk cache that is available to a single query.
# Increasing this value can lead to choosing more aggressive execution plans that assume better caching.
resource "azurerm_postgresql_flexible_server_configuration" "effective_cache_size" {
  name      = "effective_cache_size"
  server_id = azurerm_postgresql_flexible_server.default.id
  value     = local.effective_cache_size
}

# Specifies the maximum size to which the WAL files can grow.
# Adequate sizing can help prevent running out of disk space and manage the amount of data to scan for recovery.
resource "azurerm_postgresql_flexible_server_configuration" "max_wal_size" {
  name      = "max_wal_size"
  server_id = azurerm_postgresql_flexible_server.default.id
  value     = local.max_wal_size
}

# Adjusts the number of concurrent disk I/O operations PostgreSQL expects can be executed simultaneously.
# Tuning this value can improve performance on systems with SSDs or multiple disks.
resource "azurerm_postgresql_flexible_server_configuration" "effective_io_concurrency" {
  name      = "effective_io_concurrency"
  server_id = azurerm_postgresql_flexible_server.default.id
  value     = local.effective_io_concurrency
}
