#!/bin/bash

# Function to check the exit status and display an error message if it failed
check_exit_status() {
  if [ $? -ne 0 ]; then
    echo "Error: $1"
    exit 1
  fi
}

# Specify the username for the new IAM user
USER_NAME="terraform_user"

# Create IAM User and capture the response
USER_RESPONSE=$(aws iam create-user --user-name "$USER_NAME")
check_exit_status "Failed to create IAM user."

# Extract User ARN from the response
USER_ARN=$(echo "$USER_RESPONSE" | jq -r '.User.Arn')

# Attach Admin Access Policy to IAM User
aws iam attach-user-policy --user-name "$USER_NAME" --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
check_exit_status "Failed to attach Admin Access Policy to IAM user."

# Create Access and Secret Access Keys
CREDS_JSON=$(aws iam create-access-key --user-name "$USER_NAME")
check_exit_status "Failed to create Access and Secret Access Keys."

# Extract Access Key and Secret Access Key
ACCESS_KEY=$(echo "$CREDS_JSON" | jq -r '.AccessKey.AccessKeyId')
SECRET_KEY=$(echo "$CREDS_JSON" | jq -r '.AccessKey.SecretAccessKey')

# Create AWS Secrets Manager for storing access keys
SECRET_NAME="terraform_user_secrets"
SECRET_DESCRIPTION="Secrets for Terraform user $USER_NAME"
SECRET_JSON="{\"AccessKey\":\"$ACCESS_KEY\",\"SecretAccessKey\":\"$SECRET_KEY\"}"
SECRET_ARN=$(aws secretsmanager create-secret --name "$SECRET_NAME" --description "$SECRET_DESCRIPTION" --secret-string "$SECRET_JSON" | jq -r '.ARN')
check_exit_status "Failed to create AWS Secrets Manager."

# Create S3 Bucket
S3_BUCKET_NAME="tf-remote-bucket-digitalden"
aws s3 mb "s3://$S3_BUCKET_NAME" --region "us-east-1"

# Enable Versioning for S3 Bucket
aws s3api put-bucket-versioning --bucket "$S3_BUCKET_NAME" --versioning-configuration Status=Enabled

# Create DynamoDB Table
aws dynamodb create-table \
  --table-name "tf-lock-table" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 \
  --region "us-east-1"

# Create a Resource Group
RESOURCE_GROUP_NAME="TerraformResources"
aws resource-groups create-group --name "$RESOURCE_GROUP_NAME" --resource-query '{"Type":"TAG_FILTERS_1_0","Query":"{\"ResourceTypeFilters\":[\"AWS::AllSupported\"],\"TagFilters\":[{\"Key\":\"Name\",\"Values\":[\"terraform_user\",\"tf-remote-bucket-digitalden\",\"tf-lock-table\"]}]}'
check_exit_status "Failed to create Resource Group."

# Add resources to the Resource Group
aws resource-groups tag --resource-arns "$USER_ARN" "arn:aws:s3:::$S3_BUCKET_NAME" "arn:aws:dynamodb:us-east-1:123456789012:table/tf-lock-table" --tags Key=Name,Value="$RESOURCE_GROUP_NAME"
check_exit_status "Failed to tag resources and add them to the Resource Group."

# Apply the sed command to a JSON file
sed -e "s/RESOURCE/arn:aws:s3:::$S3_BUCKET_NAME/g" \
    -e "s/KEY/terraform.tfstate/g" \
    -e "s|ARN|$USER_ARN|g" "$(dirname "$0")/s3_policy.json" > new-policy.json
aws s3api put-bucket-policy --bucket "$S3_BUCKET_NAME" --policy file://new-policy.json
rm new-policy.json

# Echo a confirmation message
echo "Resources created in AWS region: us-east-1"
echo "IAM User created successfully. Username: $USER_NAME"
echo "S3 Bucket created successfully: $S3_BUCKET_NAME (Versioning enabled)"
echo "DynamoDB Table created successfully: tf-lock-table"
echo "AWS Secrets Manager created successfully: $SECRET_NAME"
echo "Resource Group created successfully: $RESOURCE_GROUP_NAME"
echo "Script execution completed successfully."