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
terraform init

# Validate the Terraform configuration
echo "Validating Terraform configuration..."
terraform validate
if [ $? -ne 0 ]; then
  echo "Terraform validation failed. Exiting."
  exit 1
fi

# Plan the Terraform changes
echo "Creating Terraform plan..."
terraform plan -var-file=$TFVARS_FILE -out=tf-backend-plan
if [ $? -ne 0 ]; then
  echo "Terraform plan failed. Exiting."
  exit 1
fi

# Ask for user confirmation before applying
read -p "Do you want to apply this plan? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
  echo "Terraform apply cancelled."
  exit 0
fi

# Apply the Terraform changes
echo "Applying Terraform changes..."
terraform apply "tf-backend-plan"
if [ $? -ne 0 ]; then
  echo "Terraform apply failed. Exiting."
  exit 1
fi

echo "Terraform apply completed successfully."
