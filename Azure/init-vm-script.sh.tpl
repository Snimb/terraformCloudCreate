#!/bin/bash

# Update and upgrade the system
sudo apt-get update -y && sudo apt-get upgrade -y

# Install PostgreSQL client
sudo apt-get install -y postgresql-client

# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Log in to Azure CLI using the VM's managed identity
az login --identity

# Retrieve the PostgreSQL connection string from Azure Key Vault
conn_str=$(az keyvault secret show --name "${secret_name}" --vault-name "${key_vault_name}" --query value -o tsv)

# Example: Export as an environment variable
echo "export PSQL_CONN_STR='$conn_str'" >> ~/.bashrc

# Reload .bashrc to apply the environment variable
source ~/.bashrc

# Print a message to indicate the end of the script execution
echo "Initialization script completed successfully"
