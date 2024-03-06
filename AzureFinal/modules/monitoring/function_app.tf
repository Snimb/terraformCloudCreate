### ACTION GROUP ###
resource "azurerm_monitor_action_group" "ag" {
  name                = "monitor-action-group"
  resource_group_name = azurerm_resource_group.diag.name
  short_name          = "ag"

  /* webhook_receiver {
    name                    = "callfunction"
    service_uri             = "https://${azurerm_linux_function_app.diag_app.default_hostname}"
    use_common_alert_schema = true
  }*/

  azure_function_receiver {
    name                     = "azure-function-receiver"
    function_app_resource_id = azurerm_linux_function_app.diag_app.id
    function_name            = "MyFunctionApp"
    # http_trigger_url         = "https://${azurerm_linux_function_app.diag_app.default_hostname}/api/autoscaling?code=${var.function_app_key}"
    http_trigger_url = "https://${azurerm_linux_function_app.diag_app.default_hostname}/api/MyFunctionApp"
  }

  dynamic "email_receiver" {
    for_each = var.email_receivers

    content {
      name                    = email_receiver.value.name
      email_address           = email_receiver.value.email_address
      use_common_alert_schema = true
    }
  }
  depends_on = [azurerm_linux_function_app.diag_app,
  ]
}

resource "azurerm_service_plan" "diag_service_plan" {
  name                = "diag-appserviceplan"
  location            = azurerm_resource_group.diag.location
  resource_group_name = azurerm_resource_group.diag.name

  # App Service plan specific settings
  sku_name = "Y1"
  os_type  = "Linux" # Change to "Windows" if you are using Windows-based functions
}


resource "azurerm_linux_function_app" "diag_app" {
  name                       = lower("functionapp-${random_pet.name_prefix.id}-${local.environment}")
  location                   = azurerm_resource_group.diag.location
  resource_group_name        = azurerm_resource_group.diag.name
  service_plan_id            = azurerm_service_plan.diag_service_plan.id
  storage_account_name       = azurerm_storage_account.st.name
  storage_account_access_key = azurerm_storage_account.st.primary_access_key
  zip_deploy_file            = data.archive_file.app_zip.output_path
  identity {
    type = "SystemAssigned"
  }

  site_config {}
  # If you were using app settings, they would still be applicable here
  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "python" # Or your runtime of choice: node, python, etc.
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
    "AzureWebJobsStorage"      = azurerm_storage_account.st.primary_connection_string
    "KEY_VAULT_URL"            = var.module_keyvault.vault_uri  # Set the Key Vault URL here


    # "WEBSITE_RUN_FROM_PACKAGE" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.funcapp_blob_url.id})"
    # "FunctionAppKey"           = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.function_app_key.id})"

  }

  # Include other properties as required for your configuration
}

resource "azurerm_linux_function_app_slot" "diag_app_slot" {
  name                 = "diag-linux-function-app-slot"
  function_app_id      = azurerm_linux_function_app.diag_app.id
  storage_account_name = azurerm_storage_account.st.name

  site_config {}
}

data "archive_file" "app_zip" {
  type        = "zip"
  source_dir  = "C:/Users/sinwi/Documents/terraformCloudCreate/AzureFinal/MyFunctionApp"
  output_path = "C:/Users/sinwi/Documents/terraformCloudCreate/AzureFinal/MyFunctionApp/functionapp.zip"
}

resource "azurerm_role_assignment" "function_app_sql_contributor" {
  scope                = var.module_postgres_fs_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_linux_function_app.diag_app.identity.0.principal_id
}

resource "azurerm_role_assignment" "func_app_reader" {
  scope                = "subscriptions/${data.azurerm_subscriptions.available.subscriptions[0].subscription_id}"
  role_definition_name = "Reader"
  principal_id         = azurerm_linux_function_app.diag_app.identity.0.principal_id
  depends_on = [
    azurerm_linux_function_app.diag_app,
    var.module_keyvault
  ]
}

resource "azurerm_key_vault_access_policy" "function_app_policy" {
  key_vault_id = var.module_keyvault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_linux_function_app.diag_app.identity.0.principal_id

  secret_permissions = ["Get"]
    
  storage_permissions = [
    "get", "list", "delete", "set", "update", "regeneratekey", "setsas", "listsas", "getsas", "deletesas" # Permissions required for managing storage accounts
  ]
}



/*resource "azurerm_storage_blob" "app_blob" {
  name                   = "functionapp.zip"
  storage_account_name   = azurerm_storage_account.st.name
  storage_container_name = azurerm_storage_container.func_app_container.name
  type                   = "Block"
  source                 = data.archive_file.app_zip.output_path
}
*/

/*data "azurerm_function_app_host_keys" "hostkeys" {
  name                = "funcAppKeys"
  resource_group_name = azurerm_resource_group.diag.name
  depends_on = [
    azurerm_linux_function_app.diag_app
  ]
}

resource "azurerm_key_vault_secret" "function_app_key" {
  name         = "FunctionAppKey"
  value        = azurerm_function_app_host_keys.hostkeys.default_function_key.value
  key_vault_id = var.module_keyvault_id
 
}*/
