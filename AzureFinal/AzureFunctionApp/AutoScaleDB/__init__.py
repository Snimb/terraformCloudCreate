# Import necessary modules for Azure function and database operations
import azure.functions as func
import datetime
import logging
import json
import time
from azure.identity import (
    DefaultAzureCredential,
)  # Handles authentication across Azure services
from azure.storage.blob import BlobServiceClient  # Interact with Azure Blob Storage
import os  # Access environment variables
from azure.mgmt.rdbms.postgresql_flexibleservers.models import Configuration
from azure.mgmt.rdbms.postgresql_flexibleservers import PostgreSQLManagementClient
# from azure.monitor.query import MetricsQueryClient, MetricAggregationType

# Define the ordered SKU levels from lowest to highest capacity for General Purpose (GP) tiers
# Uncomment the list below to use General Purpose SKUs
gp_sku_details = {
    "Standard_D2ds_v5": {"memory_gb": 8, "cpu_cores": 2, "tier": "GeneralPurpose"},
    "Standard_D4ds_v5": {"memory_gb": 16, "cpu_cores": 4, "tier": "GeneralPurpose"},
    "Standard_D8ds_v5": {"memory_gb": 32, "cpu_cores": 8, "tier": "GeneralPurpose"},
    "Standard_D16ds_v5": {"memory_gb": 64, "cpu_cores": 16, "tier": "GeneralPurpose"},
    "Standard_D32ds_v5": {"memory_gb": 128, "cpu_cores": 32, "tier": "GeneralPurpose"},
    "Standard_D48ds_v5": {"memory_gb": 192, "cpu_cores": 48, "tier": "GeneralPurpose"},
    "Standard_D64ds_v5": {"memory_gb": 256, "cpu_cores": 64, "tier": "GeneralPurpose"},
    "Standard_D96ds_v5": {"memory_gb": 384, "cpu_cores": 96, "tier": "GeneralPurpose"},
}

# Define the ordered SKU levels from lowest to highest capacity for Memory Optimized (MO) tiers
# Uncomment the list below to use Memory Optimized SKUs
"""
mo_sku_details = {
    "Standard_E2ds_v5": {"memory_gb": 16, "cpu_cores": 2, "tier": "MemoryOptimized"},
    "Standard_E4ds_v5": {"memory_gb": 32, "cpu_cores": 4, "tier": "MemoryOptimized"},
    "Standard_E8ds_v5": {"memory_gb": 64, "cpu_cores": 8, "tier": "MemoryOptimized"},
    "Standard_E16ds_v5": {"memory_gb": 128, "cpu_cores": 16, "tier": "MemoryOptimized"},
    "Standard_E20ds_v5": {"memory_gb": 160, "cpu_cores": 20, "tier": "MemoryOptimized"},
    "Standard_E32ds_v5": {"memory_gb": 256, "cpu_cores": 32, "tier": "MemoryOptimized"},
    "Standard_E48ds_v5": {"memory_gb": 384, "cpu_cores": 48, "tier": "MemoryOptimized"},
    "Standard_E64ds_v5": {"memory_gb": 512, "cpu_cores": 64, "tier": "MemoryOptimized"},
    "Standard_E96ds_v5": {"memory_gb": 768, "cpu_cores": 96, "tier": "MemoryOptimized"},
}
"""
# Decide which SKU list to use here, comment out the one you don't need
sku_details = gp_sku_details
# sku_details = mo_sku_details

sku_levels = sorted(sku_details.keys(), key=lambda x: sku_details[x]["cpu_cores"])


# Use this connection string to access your blob storage
# STORAGE_CONNECTION_STRING = get_storage_connection_string()
STORAGE_CONNECTION_STRING = os.environ.get("AzureWebJobsStorage")
BLOB_CONTAINER_NAME = os.environ.get("BLOB_CONTAINER_NAME")

"""
def get_latest_metrics(resource_id, metric_names):
    credential = DefaultAzureCredential()
    client = MetricsQueryClient(credential)
    metrics_response = client.query_resource(
        resource_id,
        metric_names,
        duration='PT5M',  # Last 5 minutes; adjust as necessary
        aggregations=[MetricAggregationType.AVERAGE],
    )
    metrics_data = {}
    for metric in metrics_response.metrics:
        for time_series in metric.timeseries:
            for data in time_series.data:
                # Assuming you want the latest data point; adjust as needed
                if data.average is not None:
                    metrics_data[metric.name] = data.average
    return metrics_data
"""

# Function to calculate new PostgreSQL configuration values based on the SKU
def calculate_postgres_configs(sku_name):
    details = sku_details.get(sku_name)
    if not details:
        raise ValueError(f"Unsupported SKU: {sku_name}")

    # Convert memory from GB to KB and calculate different memory metrics
    total_memory_kb = details["memory_gb"] * 1024 * 1024  # total memory in KB
    total_memory_8kb = total_memory_kb / 8  # total memory in 8KB chunks

    # Calculate configuration values based on memory and CPU
    configs = {
        "shared_buffers": f"{int(total_memory_8kb / 4)}",  # 25% of total memory, adjusted for 8KB units
        "work_mem": f"{int(total_memory_kb / 16) - 1}",  # 6% of total memory
        "maintenance_work_mem": f"{int(total_memory_kb / 16) - 1}",  # 6% of total memory, slightly reduced
        "effective_cache_size": f"{int(total_memory_kb / 2)}",  # 50% of total memory
        "max_wal_size": f"{int((details['memory_gb'] * 1024) / 4)}",  # 25% of total memory, converted from GB to MB
        "effective_io_concurrency": f"{details['cpu_cores'] * 2}",  # 2 times the CPU cores
    }
    return configs


def update_postgres_configs(resource_group, server_name, new_configs):
    for config_name, config_value in new_configs.items():
        subscription_id = os.environ.get("SUBSCRIPTION_ID")
        credentials = DefaultAzureCredential()
        client = PostgreSQLManagementClient(credentials, subscription_id)
        print(f"Updating {config_name} to {config_value}")  # Logging
        client.configurations.begin_update(
            resource_group_name=resource_group,
            server_name=server_name,
            configuration_name=config_name,
            parameters=Configuration(value=str(config_value)),  # Ensure value is string
        ).result()  # Wait for the operation to complete


# Function to read the last scale-up time from blob storage
def get_last_scale_up_time():
    blob_service_client = BlobServiceClient.from_connection_string(
        STORAGE_CONNECTION_STRING
    )
    blob_client = blob_service_client.get_blob_client(
        container=BLOB_CONTAINER_NAME, blob="scale-up-timestamp.txt"
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
    try:
        blob_service_client = BlobServiceClient.from_connection_string(
            STORAGE_CONNECTION_STRING
        )
        blob_client = blob_service_client.get_blob_client(
            container=BLOB_CONTAINER_NAME, blob="scale-up-timestamp.txt"
        )
        current_time_str = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        blob_client.upload_blob(current_time_str, overwrite=True)
    except Exception as e:
        logging.error(f"Failed to set last scale-up time: {e}")


# Function to read the last scale-down time from blob storage
def get_last_scale_down_time():
    blob_service_client = BlobServiceClient.from_connection_string(
        STORAGE_CONNECTION_STRING
    )
    blob_client = blob_service_client.get_blob_client(
        container=BLOB_CONTAINER_NAME, blob="scale-down-timestamp.txt"
    )
    try:
        blob_download = blob_client.download_blob()
        last_scale_down_time_str = blob_download.readall().decode("utf-8")
        return datetime.datetime.strptime(last_scale_down_time_str, "%Y-%m-%d %H:%M:%S")
    except Exception as e:
        # If there's any issue reading the blob, assume scale-down can proceed
        return datetime.datetime.min


# Function to write the current time as the last scale-down time to blob storage
def set_last_scale_down_time():
    try:
        blob_service_client = BlobServiceClient.from_connection_string(
            STORAGE_CONNECTION_STRING
        )
        blob_client = blob_service_client.get_blob_client(
            container=BLOB_CONTAINER_NAME, blob="scale-down-timestamp.txt"
        )
        current_time_str = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        blob_client.upload_blob(current_time_str, overwrite=True)
    except Exception as e:
        logging.error(f"Failed to set last scale-down time: {e}")


def scale_postgresql_server(resource_group, server_name, new_sku_name):
    blob_service_client = BlobServiceClient.from_connection_string(
        STORAGE_CONNECTION_STRING
    )

    retries = 3  # Max number of retries
    delay = 60  # Delay between retries in seconds

    logging.info(f"Scaling PostgreSQL server: {server_name} to SKU: {new_sku_name}")
    subscription_id = os.environ.get("SUBSCRIPTION_ID")
    credentials = DefaultAzureCredential()
    client = PostgreSQLManagementClient(credentials, subscription_id)
    server = client.servers.get(
        resource_group_name=resource_group, server_name=server_name
    )

    current_sku = server.sku.name
    logging.info(f"Current SKU: {current_sku}")

    try:
        current_sku_index = sku_levels.index(current_sku)
        new_sku_index = sku_levels.index(new_sku_name)
        is_scaling_up = new_sku_index > current_sku_index
    except ValueError as e:
        logging.error(f"An error occurred finding SKU levels: {e}")
        # Handle the error appropriately, maybe set a default behavior or halt the operation

    last_scale_down_time = get_last_scale_down_time()
    time_since_last_scale_down = datetime.datetime.now() - last_scale_down_time
    can_scale_down = time_since_last_scale_down.total_seconds() >= 12 * 3600  # 12 hours

    if not can_scale_down:
        logging.info(
            f"Scale-down operation blocked: Only {time_since_last_scale_down.total_seconds() / 3600:.2f} hours since last scale-down. 12 hours required."
        )
    # Scale up condition or scale down condition after 12 hours
    if is_scaling_up or (not is_scaling_up and can_scale_down):

        for attempt in range(retries):
            try:
                # Proceed with scaling
                server_update_parameters = {"sku": {"name": new_sku_name}}
                update_operation = client.servers.begin_update(
                    resource_group_name=resource_group,
                    server_name=server_name,
                    parameters=server_update_parameters,
                )
                update_operation.wait()  # Wait for the scaling operation to complete
                logging.info(
                    f"Successfully scaled PostgreSQL server: {server_name} to SKU: {new_sku_name}"
                )
                break  # Exit the loop if the update succeeds
            except Exception as e:
                logging.error(f"Attempt {attempt + 1} failed with error: {e}")
                if attempt < retries - 1:  # Check if more retries are allowed
                    logging.info(f"Retrying after {delay} seconds...")
                    time.sleep(delay)  # Wait before retrying
                else:
                    logging.error("All retries failed. Exiting.")
                    return  # Exit the function after all retries fail

        new_configs = calculate_postgres_configs(new_sku_name)
        # Update the PostgreSQL server configurations for the new SKU
        update_postgres_configs(client, resource_group, server_name, new_configs)
        logging.info("Updated PostgreSQL configurations based on the new SKU.")

        if not is_scaling_up:
            set_last_scale_down_time()

        # If we just scaled up, update the last scale-up time
        if is_scaling_up:
            set_last_scale_up_time()

    else:
        logging.error("Cannot scale down within 12 hours of the last scale-down.")


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


def handle_sku_change(alert_data):

    resource_group = alert_data["data"]["context"]["resourceGroupName"]
    server_name = alert_data["data"]["context"]["resourceName"]
    alert_name = alert_data["data"]["context"]["name"]
    # Skip further processing if any of the required information is missing
    if not resource_group or not server_name or not alert_name:
        logging.error("Missing essential information in the payload.")
        return

    subscription_id = os.environ.get("SUBSCRIPTION_ID")
    credentials = DefaultAzureCredential()
    client = PostgreSQLManagementClient(credentials, subscription_id)
    try:
        server = client.servers.get(
            resource_group_name=resource_group, server_name=server_name
        )
    except Exception as e:  # Catch exceptions from Azure SDK calls
        logging.error(f"Could not retrieve server info: {e}")
        return

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


def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Python HTTP trigger function processed a request.")

    try:
        # Attempt to extract alert data from request body
        alert_data_raw = req.get_body().decode(
            "utf-8"
        )  # Get raw data from request body and decode from bytes to string
        alert_data = json.loads(
            alert_data_raw
        )  # Convert raw data from JSON string to dictionary
        logging.info(f"Received payload: {alert_data}")
    except ValueError as e:
        logging.error(f"Error decoding JSON from the request body: {e}")
        return func.HttpResponse("Invalid JSON in the request body", status_code=400)
    except Exception as e:
        logging.error(f"Unexpected error: {e}")
        return func.HttpResponse(f"Unexpected error: {e}", status_code=400)

    # Ensure alert_data is a dictionary before continuing
    if not isinstance(alert_data, dict):
        logging.error("Request body is not a JSON object")
        return func.HttpResponse("Request body is not a JSON object", status_code=400)

    # Navigate through the JSON structure correctly
    try:
        # Updated line: Extract 'name' from 'context' section of the payload as 'alert_name'
        alert_name = alert_data["data"]["context"]["name"]
        if not alert_name:
            raise KeyError("Alert name not found in JSON")
    except KeyError as e:
        logging.error(f"Missing expected fields in JSON: {e}")
        return func.HttpResponse(
            f"Missing expected fields in JSON: {e}", status_code=400
        )

    # Proceed if the alert name matches known alert types
    if alert_name in [
        "cpu_usage_high-alert",
        "memory_usage_high-alert",
        "cpu_usage_low-alert",
        "memory_usage_low-alert",
    ]:
        handle_sku_change(alert_data)  # Passing the entire alert data
        return func.HttpResponse(f"Processed alert: {alert_name}", status_code=200)
    else:
        # Log and respond with an informative message if the alert name is not recognized
        logging.info(f"Unrecognized or missing alert name: {alert_name}")
        return func.HttpResponse(
            f"Unrecognized or missing alert name: {alert_name}", status_code=400
        )
