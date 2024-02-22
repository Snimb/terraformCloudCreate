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
terraform init # Use this to initialize Terraform working directory
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

# Generate a plan for destroying Terraform-managed resources
terraform plan -destroy -out="destroy-plan" -var-file="../../environments/dev/dev-variables.tfvars"

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
