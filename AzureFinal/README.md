<h1 align="center">Welcome to Terraform Azure PostgreSQL Server & Security Creation 👋</h1>
<p>
  <img alt="Version" src="https://img.shields.io/badge/version-1.0.0-blue.svg?cacheSeconds=2592000" />
</p>

> This Terraform project automates the deployment of a secure and scalable HA PostgreSQL Flexible Server environment on Azure. It comprehensively sets up a PostgreSQL server alongside essential Azure services for security and management, including KeyVault, Log Analytics, Network Watcher, Security Center, Bastion, and a Virtual Machine. Additionally, it leverages a PowerShell script for Terraform backend setup and deploys a Function App to configure the database compute tier based on Terraform-managed alerts.

## Usage

```sh
Ensure you have the following prerequisites installed and configured:
Azure CLI
Terraform 
PowerShell (for running the backend creation script)
Bash (for apply and destroy script)

1. Clone the Repository
First, clone the repository to your local machine:
git clone https://github.com/Snimb/terraformCloudCreate.git
cd terraformCloudCreate/AzureFinal

2. Log in to Azure
Use the Azure CLI to log in to your Azure account:
az login
Follow the prompts to complete the authentication process.

3. Run the Terraform Backend Creation Script
Before initializing Terraform, run the provided PowerShell script to set up the Terraform backend:
.\tf_backend.ps1
This script will create necessary Azure resources for the Terraform backend and output required configuration settings.

4. Initialize, plan and apply Terraform
Navigate to the environment's directory and initialize Terraform with the backend configuration obtained from the previous step:
cd environments/dev
../../shellscripts/tf_dev_apply.sh
When prompted, type which modules you want to make a plan for and then type 'yes' to proceed with the apply and the deployment.
```

## Author

👤 **Simon Nimb Williams**

* Github: [@Snimb](https://github.com/Snimb)

## Show your support

Give a ⭐️ if this project helped you!

***
_This README was generated with ❤️ by [readme-md-generator](https://github.com/kefranabg/readme-md-generator)_