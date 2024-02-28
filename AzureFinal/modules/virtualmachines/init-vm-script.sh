#!/bin/bash

# Accept variables passed from Terraform
# Define Key Vault details
admin_username="$1"
key_vault_name="$2"
secret_name="$3"

# Initial setup: Update system and install PostgreSQL client
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install -y postgresql-client

# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Function to log in to Azure CLI using VM's managed identity
azure_cli_login() {
    local retries=5
    local wait_time=10
    for ((i = 0; i < retries; i++)); do
        if az login --identity; then
            echo "Azure CLI login successful."
            return 0
        else
            echo "Login attempt $((i + 1))/$retries failed, retrying in $wait_time seconds..."
            sleep $wait_time
        fi
    done
    echo "Azure CLI login failed after $retries attempts."
    exit 1
}

azure_cli_login

# Retrieve the PostgreSQL connection string from Azure Key Vault and process it
echo "Retrieving secret: $secret_name from vault: $key_vault_name"
conn_str=$(az keyvault secret show --name "$secret_name" --vault-name "$key_vault_name" --query value -o tsv)

# Extract components from the connection string
username=$(echo $conn_str | grep -oP 'User ID=\K[^;]*')
password=$(echo $conn_str | grep -oP 'Password=\K[^;]*')
hostname=$(echo $conn_str | grep -oP 'Host=\K[^;]*')
dbname=$(echo $conn_str | grep -oP 'Database=\K[^;]*')
port=$(echo $conn_str | grep -oP 'Port=\K[^;]*')

# Update .pgpass file for passwordless PostgreSQL client authentication
echo "Updating .pgpass for user $username..."
pgpass_file="/home/${admin_username}/.pgpass"
echo "$hostname:$port:$dbname:$username:$password" | sudo tee -a "$pgpass_file" >/dev/null
sudo chmod 600 "$pgpass_file"
sudo chown ${admin_username}:${admin_username} "$pgpass_file"

# Persist environment variables for PostgreSQL client
echo "Persisting environment variables..."
db_env_file="/etc/profile.d/db_env.sh"
echo "export PGUSER='$username'" | sudo tee -a "$db_env_file" >/dev/null
echo "export PGPASSWORD='$password'" | sudo tee -a "$db_env_file" >/dev/null
echo "export PGHOST='$hostname'" | sudo tee -a "$db_env_file" >/dev/null
echo "export PGPORT='$port'" | sudo tee -a "$db_env_file" >/dev/null
echo "export PGDATABASE='$dbname'" | sudo tee -a "$db_env_file" >/dev/null
sudo chmod +x "$db_env_file"

echo "Initialization script completed successfully."
