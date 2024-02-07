#!/bin/bash

# Command-line arguments
SERVER_FQDN=$1
ADMIN_PASSWORD=$2
DB_NAME=$3

# Connection parameters
export PGHOST=$SERVER_FQDN
export PGUSER=postgres
export PGPORT=5432
export PGPASSWORD=$ADMIN_PASSWORD

# Recommended settings based on system resources
total_memory_mb=4096 # Example value, adjust as needed
cpu_cores=2          # Example value, adjust as needed

# Calculate settings
shared_buffers=$((total_memory_mb / 4))       # 25% of total memory
work_mem=$((total_memory_mb / 16))            # 6% of total memory
maintenance_work_mem=$((total_memory_mb / 4)) # 25% of total memory
effective_cache_size=$((total_memory_mb / 2)) # 50% of total memory
wal_buffers=16                                # 16MB recommended
min_wal_size=100                              # Starting value, adjuster as needed
max_wal_size=$((total_memory_mb / 4))         # 25% of total memory
random_page_cost=1.1                          # Adjust based on storage type
effective_io_concurrency=$((cpu_cores * 2))   # Adjust based on your system

# Apply recommended settings
psql -U "$PGUSER" -h "$PGHOST" -d "$DB_NAME" -c "
ALTER SYSTEM SET shared_buffers = '${shared_buffers}MB';
ALTER SYSTEM SET work_mem = '${work_mem}MB';
ALTER SYSTEM SET maintenance_work_mem = '${maintenance_work_mem}MB';
ALTER SYSTEM SET effective_cache_size = '${effective_cache_size}MB';
ALTER SYSTEM SET wal_buffers = '${wal_buffers}MB';
ALTER SYSTEM SET min_wal_size = '${min_wal_size}MB';
ALTER SYSTEM SET max_wal_size = '${max_wal_size}MB';
ALTER SYSTEM SET random_page_cost = '${random_page_cost}';
ALTER SYSTEM SET effective_io_concurrency = '${effective_io_concurrency}';
SELECT pg_reload_conf();
"
