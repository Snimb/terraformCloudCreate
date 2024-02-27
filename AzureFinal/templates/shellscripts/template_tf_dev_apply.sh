#!/bin/bash

# Login to Azure CLI and set the account context
if ! az account show >/dev/null 2>&1; then
    echo "Not logged in. Executing 'az login'..."
    az login
    # Optional: List all subscriptions and set a specific one
    az account list --output table
    az account set -s "<name of subscription>"
    az account show --output table
else
    echo "Already logged in."
fi

# Define the name of your Azure Key Vault
KEY_VAULT_NAME="<name of key vault>"
TENANT_ID_SECRET_NAME="<name of tenant id secret>"
SUBSCRIPTION_ID_SECRET_NAME="<name of subsription id secret >"
CLIENT_SECRET_SECRET_NAME="<name of client secret secret>"
CLIENT_ID_SECRET_NAME="<name of client id secret>"

# Fetch secrets from Azure Key Vault and set them as environment variables
export ARM_CLIENT_ID=$(az keyvault secret show --name "$CLIENT_ID_SECRET_NAME" --vault-name "$KEY_VAULT_NAME" --query value -o tsv)
export ARM_CLIENT_SECRET=$(az keyvault secret show --name "$CLIENT_SECRET_SECRET_NAME" --vault-name "$KEY_VAULT_NAME" --query value -o tsv)
export ARM_SUBSCRIPTION_ID=$(az keyvault secret show --name "$SUBSCRIPTION_ID_SECRET_NAME" --vault-name "$KEY_VAULT_NAME" --query value -o tsv)
export ARM_TENANT_ID=$(az keyvault secret show --name "$TENANT_ID_SECRET_NAME" --vault-name "$KEY_VAULT_NAME" --query value -o tsv)

# Initialize and prepare Terraform
terraform init # Remove '-reconfigure' to use existing .terraform if present
terraform validate
terraform fmt # Formats all Terraform configuration files in the directory

# Terraform state and workspace management
terraform state list
terraform workspace list
# Check if workspace exists, create if not, and select it
if terraform workspace list | grep -q 'dev'; then
    echo "Workspace 'dev' exists, selecting it."
    terraform workspace select dev
else
    echo "Creating and selecting new workspace 'dev'."
    terraform workspace new dev
    terraform workspace select dev
fi

# Plan Terraform deployment
terraform plan -out=dev-plan -var-file="../../environments/dev/dev-variables.tfvars"


# Apply the Terraform plan after manual confirmation
echo "Review the plan. Type 'yes' to apply the plan or any other key to cancel:"
read APPROVAL
if [ "$APPROVAL" = "yes" ]; then
    terraform apply "dev-plan"
    echo "Terraform apply finished."
else
    echo "Plan not applied."
fi

# Unsetting the environment variables
unset ARM_CLIENT_ID
unset ARM_CLIENT_SECRET
unset ARM_SUBSCRIPTION_ID
unset ARM_TENANT_ID
