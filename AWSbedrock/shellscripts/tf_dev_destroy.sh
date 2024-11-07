#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.

start_time=$(date +%s)  # Capture start time

# Initialize and prepare Terraform
if ! terraform init; then  # Check if Terraform initialization is successful
    echo "Terraform initialization failed. Exiting script."
    exit 1  # Exit the script with a non-zero status
fi

terraform validate
terraform fmt  # Formats all Terraform configuration files in the directory

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

echo "Select which modules to destroy (separate choices with spaces):"
echo "1 - network"
echo "2 - bedrock"
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
        MODULE_TARGETS+=("module.bedrock")
        ;;
    0)
        # Destroy all modules, so clear the array to specify no target.
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

# Plan Terraform destruction with optional targets
terraform plan ${TARGET_OPTIONS} -destroy -out=dev-destroy-plan -var-file="../../environments/dev/dev-variables.tfvars"

# Apply the destroy plan after manual confirmation
echo "Review the destroy plan. Type 'yes' to destroy resources or any other key to cancel:"
read APPROVAL
if [ "$APPROVAL" = "yes" ]; then
    terraform apply "dev-destroy-plan"
    echo "Terraform destroy finished."
else
    echo "Destroy not applied."
fi

# Unsetting the environment variables
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN

end_time=$(date +%s)  # Capture end time
duration=$((end_time - start_time))  # Calculate script duration
echo "Done! Script execution time: $duration seconds"
