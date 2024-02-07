#!/bin/bash

# Parameters
total_memory_mb=4096  # Total memory in MB
cpu_cores=2           # Number of CPU cores

# Database connection details
DB_SERVER_NAME="750h-free-psqlflexible.postgres.database.azure.com"
DB_ADMIN_USER="postgres"
DB_ADMIN_PASSWORD="P4ssw0rd!"
DB_NAME="new_db"  # The name of the new database to create

# Calculate recommended settings
recommended_shared_buffers_mb=$((total_memory_mb / 4)) # 25% of total memory
recommended_work_mem_mb=$((total_memory_mb / 16)) # 6% of total memory
recommended_maintenance_work_mem_mb=$((total_memory_mb / 4)) # 25% of total memory
recommended_effective_cache_size_mb=$((total_memory_mb / 2)) # 50% of total memory
recommended_wal_buffers_kb=$((16 * 1024)) # Generally recommended as 16MB
recommended_min_wal_size_mb=100 # Starting value, adjust as needed
recommended_max_wal_size_mb=$((total_memory_mb / 4)) # 25% of total memory
recommended_random_page_cost=1.1 # Lower for SSDs, higher for HDDs
recommended_effective_io_concurrency=$((cpu_cores * 2)) # Number of concurrent I/O operations, adjust as needed

# Attempt to create the new database if it doesn't exist
PGPASSWORD=$DB_ADMIN_PASSWORD psql -U $DB_ADMIN_USER -h $DB_SERVER_NAME -c "
DO
\$$
BEGIN
    CREATE DATABASE ${DB_NAME};
    EXCEPTION WHEN duplicate_database THEN
    -- Do nothing, and continue if the database already exists
END
\$$;
"

# Adjust the system settings
PGPASSWORD=$DB_ADMIN_PASSWORD psql -U $DB_ADMIN_USER -h $DB_SERVER_NAME -d $DB_NAME -c "
ALTER SYSTEM SET shared_buffers = '${recommended_shared_buffers_mb}MB';
ALTER SYSTEM SET work_mem = '${recommended_work_mem_mb}MB';
ALTER SYSTEM SET maintenance_work_mem = '${recommended_maintenance_work_mem_mb}MB';
ALTER SYSTEM SET effective_cache_size = '${recommended_effective_cache_size_mb}MB';
ALTER SYSTEM SET wal_buffers = '${recommended_wal_buffers_kb}kB';
ALTER SYSTEM SET min_wal_size = '${recommended_min_wal_size_mb}MB';
ALTER SYSTEM SET max_wal_size = '${recommended_max_wal_size_mb}MB';
ALTER SYSTEM SET random_page_cost = '${recommended_random_page_cost}';
ALTER SYSTEM SET effective_io_concurrency = '${recommended_effective_io_concurrency}';
SELECT pg_reload_conf();
"
