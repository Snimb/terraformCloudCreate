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
SAS_TOKEN_SECRET_NAME="sasTokenForScript"

# Fetch secrets from Azure Key Vault and set them as environment variables
export ARM_CLIENT_ID=$(az keyvault secret show --name "$CLIENT_ID_SECRET_NAME" --vault-name "$KEY_VAULT_NAME" --query value -o tsv)
export ARM_CLIENT_SECRET=$(az keyvault secret show --name "$CLIENT_SECRET_SECRET_NAME" --vault-name "$KEY_VAULT_NAME" --query value -o tsv)
export ARM_SUBSCRIPTION_ID=$(az keyvault secret show --name "$SUBSCRIPTION_ID_SECRET_NAME" --vault-name "$KEY_VAULT_NAME" --query value -o tsv)
export ARM_TENANT_ID=$(az keyvault secret show --name "$TENANT_ID_SECRET_NAME" --vault-name "$KEY_VAULT_NAME" --query value -o tsv)
export TF_VAR_sas_token=$(az keyvault secret show --name "$SAS_TOKEN_SECRET_NAME" --vault-name "$KEY_VAULT_NAME" --query value -o tsv)

# Initialize and prepare Terraform
if ! terraform init; then  # Check if Terraform initialization is successful
    echo "Terraform initialization failed. Exiting script."
    exit 1  # Exit the script with a non-zero status
fi

terraform validate
terraform fmt # Formats all Terraform configuration files in the directory

# Terraform state and workspace management after destroy if needed
terraform state list
terraform workspace list
# Check if workspace 'dev' exists, and if so, select it
if terraform workspace list | grep -q 'dev'; then
    echo "Workspace 'dev' exists, selecting it."
    terraform workspace select dev
else
    echo "Workspace 'dev' does not exist."
fi

echo "Select which modules to apply (separate choices with spaces):"
echo "1 - vnetwork"
echo "2 - database"
echo "3 - keyvault"
echo "4 - monitoring"
echo "5 - virtualmachines"
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
        MODULE_TARGETS+=("module.vnetwork")
        ;;
    2)
        MODULE_TARGETS+=("module.database")
        ;;
    3)
        MODULE_TARGETS+=("module.keyvault")
        ;;
    4)
        MODULE_TARGETS+=("module.monitoring")
        ;;
    5)
        MODULE_TARGETS+=("module.virtualmachines")
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

# Generate a plan for destroying Terraform-managed resources with optional targets
terraform plan ${TARGET_OPTIONS} -destroy -out="destroy-plan" -var-file="../../environments/dev/dev-variables.tfvars"

# Prompt for user approval to proceed with the destruction
echo "WARNING: You are about to destroy Terraform-managed infrastructure. Review the destroy plan above."
echo "Do you want to proceed with destroying the infrastructure? Type 'yes' to proceed or any other key to cancel:"
read APPROVAL
if [ "$APPROVAL" = "yes" ]; then
    # Apply the destroy plan
    terraform apply "destroy-plan"
    echo "Terraform destroy finished."
else
    echo "Destroy canceled."
fi

# Unsetting the environment variables
unset ARM_CLIENT_ID
unset ARM_CLIENT_SECRET
unset ARM_SUBSCRIPTION_ID
unset ARM_TENANT_ID
unset TF_VAR_sas_token

end_time=$(date +%s)  # Capture end time
duration=$((end_time - start_time))  # Calculate script duration
echo "Done! Script execution time: $duration seconds"