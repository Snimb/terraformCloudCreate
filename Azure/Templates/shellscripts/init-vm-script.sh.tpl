#!/bin/bash

# Update and upgrade the system
sudo apt-get update -y && sudo apt-get upgrade -y

# Install PostgreSQL client
sudo apt-get install -y postgresql-client

# Define the Key Vault and Secret names
key_vault_name="${key_vault_name}"
secret_name="${secret_name}"
client_id="${client_id}"

# Secure directory for storing sensitive information
secure_dir="/etc/myapp"
sudo mkdir "$secure_dir"

# File to store client_id and password
credentials_file="$secure_dir/credentials"
sudo touch "$credentials_file"

# Save client_id and password
echo "client_id=$client_id" | sudo tee "$credentials_file"

# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Function to log in to Azure CLI using the VM's managed identity
azure_cli_login() {
    local retries=5
    local wait_time=10
    for ((i=0; i<retries; i++)); do
        echo "Attempting to log in to Azure CLI. Attempt $((i+1))/$retries..."
        az login --identity --username "$client_id" && return 0
        echo "Login attempt failed. Waiting $wait_time seconds before retrying..."
        sleep $wait_time
    done
    echo "Failed to log in to Azure CLI after $retries attempts."
    exit 1
}

# Attempt to log in to Azure CLI
azure_cli_login

# Retrieve the PostgreSQL connection string from Azure Key Vault
conn_str=$(az keyvault secret show --name "$secret_name" --vault-name "$key_vault_name" --query value -o tsv)

# Parse the connection string
username=$(echo $conn_str | grep -oP 'User ID=\K[^;]*')
password=$(echo $conn_str | grep -oP 'Password=\K[^;]*')
hostname=$(echo $conn_str | grep -oP 'Host=\K[^;]*')
dbname=$(echo $conn_str | grep -oP 'database=\K[^;]*')
port=$(echo $conn_str | grep -oP 'Port=\K[^;]*')

# Create or update the .pgpass file
echo "$hostname:$port:$dbname:$username:$password" | sudo tee -a ~/.pgpass
sudo chmod 600 ~/.pgpass

# Export environment variables
export PGUSER=$username
export PGHOST=$hostname
export PGPORT=$port
export PGDATABASE=$dbname

# Persist environment variables
echo "export PGUSER=$username" | sudo tee -a /etc/profile.d/db_env.sh
echo "export PGHOST=$hostname" | sudo tee -a /etc/profile.d/db_env.sh
echo "export PGPORT=$port" | sudo tee -a /etc/profile.d/db_env.sh
echo "export PGDATABASE=$dbname" | sudo tee -a /etc/profile.d/db_env.sh

# Note: Avoid persisting PGPASSWORD for security reasons

# Make the script executable
sudo chmod +x /etc/profile.d/db_env.sh

echo "password=$password" | sudo tee -a "$credentials_file"

# Print a message to indicate the end of the script execution
echo "Initialization script completed successfully"
