# Import necessary modules for Azure function and database operations
import azure.functions as func
import datetime
import logging
import json
from azure.identity import DefaultAzureCredential  # Handles authentication across Azure services
from azure.mgmt.rdbms import PostgreSQLManagementClient  # Manages PostgreSQL instances
from azure.keyvault.secrets import SecretClient  # Access secrets stored in Azure Key Vault
from azure.storage.blob import BlobServiceClient  # Interact with Azure Blob Storage
import os  # Access environment variables

# Define the ordered SKU levels from lowest to highest capacity for General Purpose (GP) tiers
# Uncomment the list below to use General Purpose SKUs
gp_sku_levels = [
    "GP_Standard_D2ds_v5",  # 2 vCores, 8 GB RAM, General Purpose
    "GP_Standard_D4ds_v5",  # 4 vCores, 16 GB RAM, General Purpose
    "GP_Standard_D8ds_v5",  # 8 vCores, 32 GB RAM, General Purpose
    "GP_Standard_D16ds_v5",  # 16 vCores, 64 GB RAM, General Purpose
    "GP_Standard_D32ds_v5",  # 32 vCores, 128 GB RAM, General Purpose
    "GP_Standard_D48ds_v5",  # 48 vCores, 192 GB RAM, General Purpose
    "GP_Standard_D64ds_v5",  # 64 vCores, 256 GB RAM, General Purpose
    "GP_Standard_D96ds_v5",  # 96 vCores, 384 GB RAM, General Purpose
]

# Define the ordered SKU levels from lowest to highest capacity for Memory Optimized (MO) tiers
# Uncomment the list below to use Memory Optimized SKUs
'''
mo_sku_levels = [
    "MO_Standard_E2ds_v5",  # 2 vCores, 16 GB RAM, Memory Optimized
    "MO_Standard_E4ds_v5",  # 4 vCores, 32 GB RAM, Memory Optimized
    "MO_Standard_E8ds_v5",  # 8 vCores, 64 GB RAM, Memory Optimized
    "MO_Standard_E16ds_v5",  # 16 vCores, 128 GB RAM, Memory Optimized
    "MO_Standard_E20ds_v5",  # 20 vCores, 160 GB RAM, Memory Optimized
    "MO_Standard_E32ds_v5",  # 32 vCores, 256 GB RAM, Memory Optimized
    "MO_Standard_E48ds_v5",  # 48 vCores, 384 GB RAM, Memory Optimized
    "MO_Standard_E64ds_v5",  # 64 vCores, 512 GB RAM, Memory Optimized
    "MO_Standard_E96ds_v5",  # 96 vCores, 768 GB RAM, Memory Optimized
]
'''

# Decide which SKU list to use here, comment out the one you don't need
sku_levels = gp_sku_levels  # Uncomment this line to use General Purpose SKUs
# sku_levels = mo_sku_levels  # Uncomment this line to use Memory Optimized SKUs

# Initialize Key Vault and Secret Client
KEY_VAULT_URL = os.environ.get(
    "KEY_VAULT_URL"
)  # Set this in your Function App settings
SECRET_NAME = "storageConnectionString"  # The name of your secret

credential = DefaultAzureCredential()
client = SecretClient(vault_url=KEY_VAULT_URL, credential=credential)


# Retrieve the storage account connection string from Azure Key Vault
def get_storage_connection_string():
    return client.get_secret(SECRET_NAME).value


# Use this connection string to access your blob storage
STORAGE_CONNECTION_STRING = get_storage_connection_string()
BLOB_CONTAINER_NAME = "appfunctionblobstorage"
BLOB_NAME = "scale-up-timestamp.txt"


# Function to read the last scale-up time from blob storage
def get_last_scale_up_time():
    blob_service_client = BlobServiceClient.from_connection_string(
        STORAGE_CONNECTION_STRING
    )
    blob_client = blob_service_client.get_blob_client(
        container=BLOB_CONTAINER_NAME, blob=BLOB_NAME
    )
    try:
        blob_download = blob_client.download_blob()
        last_scale_up_time_str = blob_download.readall().decode("utf-8")
        return datetime.datetime.strptime(last_scale_up_time_str, "%Y-%m-%d %H:%M:%S")
    except Exception as e:
        # If there's any issue reading the blob, assume scale-up can proceed
        return datetime.datetime.min


# Function to write the current time as the last scale-up time to blob storage
def set_last_scale_up_time():
    blob_service_client = BlobServiceClient.from_connection_string(
        STORAGE_CONNECTION_STRING
    )
    blob_client = blob_service_client.get_blob_client(
        container=BLOB_CONTAINER_NAME, blob=BLOB_NAME
    )
    current_time_str = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    blob_client.upload_blob(current_time_str, overwrite=True)


def scale_postgresql_server(resource_group, server_name, new_sku_name):
    logging.info(f"Scaling PostgreSQL server: {server_name} to SKU: {new_sku_name}")
    credentials = DefaultAzureCredential()
    client = PostgreSQLManagementClient(credentials, subscription_id)
    server = client.servers.get(
        resource_group_name=resource_group, server_name=server_name
    )
    current_sku = server.sku.name

    # Check if we are scaling up or down
    is_scaling_up = new_sku_name > current_sku

    last_scale_up_time = get_last_scale_up_time()
    time_since_last_scale_up = datetime.datetime.now() - last_scale_up_time
    can_scale_down = time_since_last_scale_up.total_seconds() >= 12 * 3600  # 12 hours

    # Scale up condition or scale down condition after 12 hours
    if is_scaling_up or (not is_scaling_up and can_scale_down):
        # Proceed with scaling
        server_update_parameters = {"sku": {"name": new_sku_name}}
        update_operation = client.servers.begin_create_or_update(
            resource_group_name=resource_group,
            server_name=server_name,
            parameters=server_update_parameters,
        )
        update_operation.wait()  # Wait for the scaling operation to complete
        logging.info(
            f"Successfully scaled PostgreSQL server: {server_name} to SKU: {new_sku_name}"
        )

        # Restart the server after scaling
        logging.info(f"Restarting PostgreSQL server: {server_name} after scaling.")
        restart_operation = client.servers.begin_restart(
            resource_group_name=resource_group, server_name=server_name
        )
        restart_operation.wait()  # Wait for the restart to complete
        logging.info(f"Successfully restarted PostgreSQL server: {server_name}.")

        # If we just scaled up, update the last scale-up time
        if is_scaling_up:
            set_last_scale_up_time()

    else:
        # Log error if attempting to scale down before 12 hours
        logging.error("Cannot scale down within 12 hours of scaling up.")


def get_higher_sku(current_sku):
    try:
        current_index = sku_levels.index(current_sku)
        return sku_levels[min(current_index + 1, len(sku_levels) - 1)]
    except ValueError:
        return current_sku


def get_lower_sku(current_sku):
    try:
        current_index = sku_levels.index(current_sku)
        return sku_levels[max(current_index - 1, 0)]
    except ValueError:
        return current_sku


def parse_resource_id(resource_id):
    parts = resource_id.split("/")
    if len(parts) > 8:
        return parts[4], parts[8]  # Return resource group and server name
    return None, None


def handle_sku_change(alert_data):
    resource_id = (
        alert_data.get("data", {}).get("essentials", {}).get("alertTargetIDs", [])[0]
    )
    resource_group, server_name = parse_resource_id(resource_id)

    if not resource_group or not server_name:
        logging.error("Could not parse resource ID.")
        return

    # Extract the alert name to determine scaling direction
    alert_name = (
        alert_data.get("data", {})
        .get("essentials", {})
        .get("alertRule", "Unknown Alert")
    )

    credentials = DefaultAzureCredential()
    client = PostgreSQLManagementClient(credentials, subscription_id)
    server = client.servers.get(
        resource_group_name=resource_group, server_name=server_name
    )
    current_sku = server.sku.name

    # Determine new SKU based on the type of alert
    if "high" in alert_name:  # Replace with your actual condition for high usage
        new_sku_name = get_higher_sku(current_sku)
    elif "low" in alert_name:  # Replace with your actual condition for low usage
        new_sku_name = get_lower_sku(current_sku)
    else:
        logging.info("Alert does not indicate a clear scale direction.")
        return

    if new_sku_name != current_sku:
        scale_postgresql_server(resource_group, server_name, new_sku_name)


@func.HttpTrigger(
    name="req",
    methods=["post"],  # Assuming you're handling POST requests; add 'get' if needed
    authLevel=func.AuthLevel.ADMIN,
)  # Use appropriate auth level as required
def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Python HTTP trigger function processed a request.")

    # Define your Key Vault URL and the name of your secret
    KEY_VAULT_URL = "https://snimb-kv-tfstates-dev.vault.azure.net/"
    SUBSCRIPTION_ID_SECRET_NAME = "tf-subscription-id"

    # Create a secret client using the DefaultAzureCredential
    credential = DefaultAzureCredential()
    secret_client = SecretClient(vault_url=KEY_VAULT_URL, credential=credential)

    # Fetch the subscription ID from Key Vault
    global subscription_id
    subscription_id = secret_client.get_secret(SUBSCRIPTION_ID_SECRET_NAME).value

    logging.info(f"Fetched subscription ID: {subscription_id}")

    try:
        alert_data = req.get_json()
    except ValueError:
        return func.HttpResponse("Invalid body", status_code=400)

    # Extract common alert properties
    alert_name = (
        alert_data.get("data", {})
        .get("essentials", {})
        .get("alertRule", "Unknown Alert")
    )

    if alert_name in [
        "cpu_usage_high",
        "memory_usage_high",
        "cpu_usage_low",
        "memory_usage_low",
    ]:
        handle_sku_change(alert_data)

    return func.HttpResponse(f"Processed alert: {alert_name}", status_code=200)
