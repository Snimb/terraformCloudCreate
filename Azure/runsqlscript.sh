#!/bin/bash

# Command-line arguments
SERVER_FQDN=$1
ADMIN_PASSWORD=$2
DB_NAME=$3
ADMIN_USER=$4
SQL_FILE="path/to/file"  # Add a path to the SQL file

# Connection parameters
export PGHOST=$SERVER_FQDN
export PGUSER=$ADMIN_USER
export PGPORT=5432
export PGPASSWORD=$ADMIN_PASSWORD

# Execute the SQL file against the specified database
psql -U "$PGUSER" -h "$PGHOST" -d "$DB_NAME" -f "$SQL_FILE"
