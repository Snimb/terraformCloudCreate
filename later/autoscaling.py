import azure.functions as func
import logging
import json
from azure.identity import DefaultAzureCredential
from azure.mgmt.rdbms import PostgreSQLManagementClient
from azure.keyvault.secrets import SecretClient

# Define the ordered SKU levels from lowest to highest capacity for General Purpose (GP) tiers
# Uncomment the list below to use General Purpose SKUs
'''gp_sku_levels = [
    'GP_D2s_v3', 'GP_D2ds_v4', 'GP_D2ds_v5', 'GP_D2ads_v5',  # 2 vCores, 8 GiB
    'GP_D4s_v3', 'GP_D4ds_v4', 'GP_D4ds_v5', 'GP_D4ads_v5',  # 4 vCores, 16 GiB
    'GP_D8s_v3', 'GP_D8ds_v4', 'GP_D8ds_v5', 'GP_D8ads_v5',  # 8 vCores, 32 GiB
    'GP_D16s_v3', 'GP_D16ds_v4', 'GP_D16ds_v5', 'GP_D16ads_v5',  # 16 vCores, 64 GiB
    'GP_D32s_v3', 'GP_D32ds_v4', 'GP_D32ds_v5', 'GP_D32ads_v5',  # 32 vCores, 128 GiB
    'GP_D48s_v3', 'GP_D48ds_v4', 'GP_D48ds_v5', 'GP_D48ads_v5',  # 48 vCores, 192 GiB
    'GP_D64s_v3', 'GP_D64ds_v4', 'GP_D64ds_v5', 'GP_D64ads_v5',  # 64 vCores, 256 GiB
    'GP_D96ds_v5', 'GP_D96ads_v5'  # 96 vCores, 384 GiB
]'''

# Define the ordered SKU levels from lowest to highest capacity for Memory Optimized (MO) tiers
# Uncomment the list below to use Memory Optimized SKUs
'''mo_sku_levels = [
    'MO_E2s_v3', 'MO_E2ds_v4', 'MO_E2ds_v5', 'MO_E2ads_v5',  # 2 vCores, 16 GiB
    'MO_E4s_v3', 'MO_E4ds_v4', 'MO_E4ds_v5', 'MO_E4ads_v5',  # 4 vCores, 32 GiB
    'MO_E8s_v3', 'MO_E8ds_v4', 'MO_E8ds_v5', 'MO_E8ads_v5',  # 8 vCores, 64 GiB
    'MO_E16s_v3', 'MO_E16ds_v4', 'MO_E16ds_v5', 'MO_E16ads_v5',  # 16 vCores, 128 GiB
    'MO_E20ds_v4', 'MO_E20ds_v5', 'MO_E20ads_v5',  # 20 vCores, 160 GiB
    'MO_E32s_v3', 'MO_E32ds_v4', 'MO_E32ds_v5', 'MO_E32ads_v5',  # 32 vCores, 256 GiB
    'MO_E48s_v3', 'MO_E48ds_v4', 'MO_E48ds_v5', 'MO_E48ads_v5',  # 48 vCores, 384 GiB
    'MO_E64s_v3', 'MO_E64ds_v4', 'MO_E64ds_v5', 'MO_E64ads_v4',  # 64 vCores, up to 512 GiB
    'MO_E96ds_v5', 'MO_E96ads_v5'  # 96 vCores, 672 GiB
]'''

gp_sku_levels = [
    'GP_D2ds_v4', 'GP_D2ds_v5', 'GP_D2ads_v5',  # 2 vCores, 8 GiB
    'GP_D4ds_v4', 'GP_D4ds_v5', 'GP_D4ads_v5',  # 4 vCores, 16 GiB
    'GP_D8ds_v4', 'GP_D8ds_v5', 'GP_D8ads_v5',  # 8 vCores, 32 GiB
    'GP_D16ds_v4', 'GP_D16ds_v5', 'GP_D16ads_v5',  # 16 vCores, 64 GiB
    'GP_D32ds_v4', 'GP_D32ds_v5', 'GP_D32ads_v5',  # 32 vCores, 128 GiB
    'GP_D48ds_v4', 'GP_D48ds_v5', 'GP_D48ads_v5',  # 48 vCores, 192 GiB
]

# Decide which SKU list to use here, comment out the one you don't need
sku_levels = gp_sku_levels  # Uncomment this line to use General Purpose SKUs
# sku_levels = mo_sku_levels  # Uncomment this line to use Memory Optimized SKUs

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

def scale_postgresql_server(resource_group, server_name, new_sku_name):
    logging.info(f"Scaling PostgreSQL server: {server_name} to SKU: {new_sku_name}")
    credentials = DefaultAzureCredential()
    client = PostgreSQLManagementClient(credentials, subscription_id)
    
    # Construct new server settings with updated SKU
    server_update_parameters = {'sku': {'name': new_sku_name}}
    
    # Update the server SKU
    update_operation = client.servers.begin_create_or_update(
        resource_group_name=resource_group, 
        server_name=server_name, 
        parameters=server_update_parameters
    )
    update_operation.wait()  # Wait for the scaling operation to complete
    logging.info(f"Successfully scaled PostgreSQL server: {server_name} to SKU: {new_sku_name}")

    # Restart the server after scaling
    logging.info(f"Restarting PostgreSQL server: {server_name} after scaling.")
    restart_operation = client.servers.begin_restart(
        resource_group_name=resource_group, 
        server_name=server_name
    )
    restart_operation.wait()  # Wait for the restart to complete
    logging.info(f"Successfully restarted PostgreSQL server: {server_name}.")


def parse_resource_id(resource_id):
    parts = resource_id.split('/')
    if len(parts) > 8:
        return parts[4], parts[8]  # Return resource group and server name
    return None, None

def handle_sku_change(alert_data):
    resource_id = alert_data.get('data', {}).get('essentials', {}).get('alertTargetIDs', [])[0]
    resource_group, server_name = parse_resource_id(resource_id)
    
    if not resource_group or not server_name:
        logging.error("Could not parse resource ID.")
        return

    # Extract the alert name to determine scaling direction
    alert_name = alert_data.get('data', {}).get('essentials', {}).get('alertRule', 'Unknown Alert')
    
    credentials = DefaultAzureCredential()
    client = PostgreSQLManagementClient(credentials, subscription_id)
    server = client.servers.get(resource_group_name=resource_group, server_name=server_name)
    current_sku = server.sku.name

    # Determine new SKU based on the type of alert
    if 'high' in alert_name:  # Replace with your actual condition for high usage
        new_sku_name = get_higher_sku(current_sku)
    elif 'low' in alert_name:  # Replace with your actual condition for low usage
        new_sku_name = get_lower_sku(current_sku)
    else:
        logging.info("Alert does not indicate a clear scale direction.")
        return

    if new_sku_name != current_sku:
        scale_postgresql_server(resource_group, server_name, new_sku_name)

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

# Define your Key Vault URL and the name of your secret
    KEY_VAULT_URL = "https://snimb-kv-tfstates-dev.vault.azure.net/"
    SUBSCRIPTION_ID_SECRET_NAME = "tf-subscription-id"

    # Create a secret client using the DefaultAzureCredential
    credential = DefaultAzureCredential()
    secret_client = SecretClient(vault_url=KEY_VAULT_URL, credential=credential)

    # Fetch the subscription ID from Key Vault
    global subscription_id  # Declare as global if you're going to use it outside of main function
    subscription_id = secret_client.get_secret(SUBSCRIPTION_ID_SECRET_NAME).value

    logging.info(f"Fetched subscription ID: {subscription_id}")
    
    try:
        alert_data = req.get_json()
    except ValueError:
        return func.HttpResponse("Invalid body", status_code=400)

    # Extract common alert properties
    alert_name = alert_data.get('data', {}).get('essentials', {}).get('alertRule', 'Unknown Alert')

    if alert_name in ['cpu_usage_high', 'memory_usage_high', 'storage_usage_high', 'cpu_usage_low', 'memory_usage_low', 'storage_usage_low']:
        handle_sku_change(alert_data)

    return func.HttpResponse(f"Processed alert: {alert_name}")
