## Cloud PostgreSQL Server Setup with Terraform and Bash

This project automates the deployment of a PostgreSQL Server on both Azure and AWS and configures its parameters for optimal performance. It utilizes Terraform for infrastructure provisioning and a Bash script for post-deployment database configuration.

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html)
- Cloud CLI:
  - [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) for Azure
  - [AWS CLI](https://aws.amazon.com/cli/) for AWS
- [PostgreSQL Client (psql)](https://www.postgresql.org/download/)

### Files Included

- `Azure/main.tf` and `AWS/main.tf`: Terraform configuration files that define the cloud resources.
- `Azure/auto-edit-configs.sh` and `AWS/auto-edit-configs.sh`: Bash scripts that configure the PostgreSQL server after deployment.
- `Azure/provider.tf` and `AWS/provider.tf`: Terraform configuration files that define the cloud provider.

### Usage

#### For Azure

1. **Terraform Initialization and Deployment**

    Navigate to the Azure directory:
    ```bash
    cd Azure
    ```

    Initialize Terraform:
    ```bash
    terraform init
    ```

    Deploy the infrastructure:
    ```bash
    terraform apply
    ```

    Confirm the actions proposed by Terraform by typing `yes` when prompted.

2. **PostgreSQL Configuration with Bash Script**

    After the Terraform deployment completes, the `auto-edit-configs.sh` script will automatically run to configure the PostgreSQL server. 

    If you need to run the script manually or make adjustments, ensure it has execute permissions:
    ```bash
    chmod +x auto-edit-configs.sh
    ./auto-edit-configs.sh
    ```

    The script calculates optimal settings for `shared_buffers`, `work_mem`, and other parameters based on the server's memory and CPU cores. It then applies these settings to the PostgreSQL server.

#### For AWS

1. **Terraform Initialization and Deployment**

    Navigate to the AWS directory:
    ```bash
    cd AWS
    ```

    Initialize Terraform:
    ```bash
    terraform init
    ```

    Deploy the infrastructure:
    ```bash
    terraform apply
    ```

    Confirm the actions proposed by Terraform by typing `yes` when prompted.

2. **PostgreSQL Configuration with Bash Script**

    After the Terraform deployment completes, the `auto-edit-configs.sh` script will automatically run to configure the PostgreSQL server. 

    If you need to run the script manually or make adjustments, ensure it has execute permissions:
    ```bash
    chmod +x auto-edit-configs.sh
    ./auto-edit-configs.sh
    ```

    The script calculates optimal settings for `shared_buffers`, `work_mem`, and other parameters based on the server's memory and CPU cores. It then applies these settings to the PostgreSQL server.

### Configuration

- **Terraform (`main.tf`):** Update the variables (resource group name, location, server name, etc.) to match your cloud setup.
  
- **Bash Script (`auto-edit-configs.sh`):** 
    - Set the database server name (`DB_SERVER_NAME`), admin username (`DB_ADMIN_USER`), and password (`DB_ADMIN_PASSWORD`) in the script.
    - If you know your server's memory and CPU cores, update `total_memory_mb` and `cpu_cores` variables. Alternatively, you can modify the script to fetch these values dynamically.

### Security Notice

- Avoid hardcoding sensitive information such as the database password in scripts. Consider using environment variables or a secrets manager.
- Ensure that the machine where you're running Terraform can connect to the cloud PostgreSQL Flexible Server. The server's firewall rules must allow connections from your machine's IP address.

### Support

- For issues, suggestions, or contributions, please open an issue or pull request in this repository.
