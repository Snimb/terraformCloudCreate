#!/bin/bash

# Login to Azure CLI and set the account context
if ! az account show >/dev/null 2>&1; then
    echo "Not logged in. Executing 'az login'..."
    az login
    # Optional: List all subscriptions and set a specific one
    az account list --output table
    az account set -s "Azure subscription Simon Williams"
    az account show --output table
else
    echo "Already logged in."
fi

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
