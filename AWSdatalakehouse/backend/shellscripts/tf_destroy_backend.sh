#!/bin/bash

# Set variables for your Terraform workspace
TFVARS_FILE="backend.tfvars"

# Check if terraform is installed
if ! [ -x "$(command -v terraform)" ]; then
  echo 'Error: terraform is not installed.' >&2
  exit 1
fi

# Initialize Terraform (downloads providers, etc.)
echo "Initializing Terraform..."
# Initialize and prepare Terraform
if ! terraform init; then  # Check if Terraform initialization is successful
    echo "Terraform initialization failed. Exiting script."
    exit 1  # Exit the script with a non-zero status
fi

# Validate the Terraform configuration
echo "Validating Terraform configuration..."
terraform validate
if [ $? -ne 0 ]; then
  echo "Terraform validation failed. Exiting."
  exit 1
fi

# Plan the Terraform destroy (optional, for review)
echo "Creating Terraform destroy plan..."
terraform plan -destroy -var-file=$TFVARS_FILE -out=tf-backend-destroyplan
if [ $? -ne 0 ]; then
  echo "Terraform destroy plan failed. Exiting."
  exit 1
fi

# Ask for user confirmation before destroying
read -p "Are you sure you want to destroy all Terraform-managed infrastructure? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
  echo "Terraform destroy cancelled."
  exit 0
fi

# Apply the Terraform destroy
echo "Destroying Terraform-managed infrastructure..."
terraform apply "tf-backend-destroyplan"
if [ $? -ne 0 ]; then
  echo "Terraform apply failed. Exiting."
  exit 1
fi

echo "Terraform destroy completed successfully."
