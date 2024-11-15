#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.

start_time=$(date +%s)  # Capture start time

# Login to Azure CLI and set the account context
if ! az account show >/dev/null 2>&1; then
    echo "Not logged in. Executing 'az login'..."
    az login
    # Optional: List all subscriptions and set a specific one
    az account list --output table
    az account set -s "Azure subscription 1"
    az account show --output table
else
    echo "Already logged in."
fi

# Define the name of your Azure Key Vault
KEY_VAULT_NAME="snimb-kv-tfstates-dev"
TENANT_ID_SECRET_NAME="tf-tenant-id"
SUBSCRIPTION_ID_SECRET_NAME="tf-subscription-id"
CLIENT_SECRET_SECRET_NAME="tf-client-secret"
CLIENT_ID_SECRET_NAME="tf-client-id"

# Fetch secrets from Azure Key Vault and set them as environment variables
export ARM_CLIENT_ID=$(az keyvault secret show --name "$CLIENT_ID_SECRET_NAME" --vault-name "$KEY_VAULT_NAME" --query value -o tsv)
export ARM_CLIENT_SECRET=$(az keyvault secret show --name "$CLIENT_SECRET_SECRET_NAME" --vault-name "$KEY_VAULT_NAME" --query value -o tsv)
export ARM_SUBSCRIPTION_ID=$(az keyvault secret show --name "$SUBSCRIPTION_ID_SECRET_NAME" --vault-name "$KEY_VAULT_NAME" --query value -o tsv)
export ARM_TENANT_ID=$(az keyvault secret show --name "$TENANT_ID_SECRET_NAME" --vault-name "$KEY_VAULT_NAME" --query value -o tsv)

# Initialize and prepare Terraform
if ! terraform init; then  # Check if Terraform initialization is successful
    echo "Terraform initialization failed. Exiting script."
    exit 1  # Exit the script with a non-zero status
fi

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

echo "Select which modules to apply (separate choices with spaces):"
echo "1 - network"
echo "2 - lakehouse"
echo "3 - databricks"
echo "0 - All (default)"
read -p "Enter your choices (press Enter for All): " MODULE_CHOICES

# Default to '0' if no choices provided
if [ -z "$MODULE_CHOICES" ]; then
    MODULE_CHOICES="0"
fi

MODULE_TARGETS=()
for choice in $MODULE_CHOICES; do
    case $choice in
    1)
        MODULE_TARGETS+=("module.network")
        ;;
    2)
        MODULE_TARGETS+=("module.lakehouse")
        ;;
    3)
        MODULE_TARGETS+=("module.databricks")
        ;;
    0)
        # Apply to all modules, so clear the array to specify no target.
        MODULE_TARGETS=()
        break # Exit the loop as 'All' means no specific target is needed.
        ;;
    *)
        echo "Invalid choice: $choice. Skipping."
        ;;
    esac
done

# Construct the Terraform target option string
TARGET_OPTIONS=""
for target in "${MODULE_TARGETS[@]}"; do
    TARGET_OPTIONS+=" -target=$target"
done

# Plan Terraform deployment with optional targets
terraform plan ${TARGET_OPTIONS} -out=dev-plan -var-file="../../environments/dev/dev-variables.tfvars"

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

end_time=$(date +%s)  # Capture end time
duration=$((end_time - start_time))  # Calculate script duration
echo "Done! Script execution time: $duration seconds"