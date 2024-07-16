### ACTION GROUP ###
resource "azurerm_monitor_action_group" "ag" {
  name                = "monitor-action-group"
  resource_group_name = azurerm_resource_group.diag.name
  short_name          = "ag"

  azure_function_receiver {
    name                     = "azure-function-receiver"
    function_app_resource_id = azurerm_linux_function_app.diag_app.id
    function_name            = "AutoScaleDB"
    http_trigger_url         = "https://${azurerm_linux_function_app.diag_app.default_hostname}/api/AutoScaleDB?code=${data.azurerm_function_app_host_keys.func_app_keys.primary_key}"
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
    data.azurerm_function_app_host_keys.func_app_keys
  ]
}

resource "azurerm_service_plan" "diag_service_plan" {
  name                = "diag-appserviceplan"
  location            = azurerm_resource_group.diag.location
  resource_group_name = azurerm_resource_group.diag.name
  sku_name            = var.sku_name_service_plan
  os_type             = "Linux" # Change to "Windows" if you are using Windows-based functions
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

  site_config {
    application_insights_key               = azurerm_application_insights.linux-application-insights.instrumentation_key
    application_insights_connection_string = azurerm_application_insights.linux-application-insights.connection_string
    always_on                              = var.funcapp_allways_on # Enable Always On
    application_stack {
      python_version = "3.11"
    }
    vnet_route_all_enabled = true
  }

  # If you were using app settings, they would still be applicable here
  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"       = "python" # Or your runtime of choice: node, python, etc.
    "WEBSITE_RUN_FROM_PACKAGE"       = "0"
    "AzureWebJobsStorage"            = azurerm_storage_account.st.primary_connection_string
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.linux-application-insights.instrumentation_key
    "SUBSCRIPTION_ID"                = data.azurerm_client_config.current.subscription_id
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = true
    "BLOB_CONTAINER_NAME"            = azurerm_storage_container.func_app_container.name
  }
}

resource "azurerm_application_insights" "linux-application-insights" {
  name                = "application-insights-functionapp"
  location            = azurerm_resource_group.diag.location
  resource_group_name = azurerm_resource_group.diag.name
  application_type    = "other"
}

resource "azurerm_linux_function_app_slot" "diag_app_slot" {
  name                 = "diag-linux-function-app-slot"
  function_app_id      = azurerm_linux_function_app.diag_app.id
  storage_account_name = azurerm_storage_account.st.name

  site_config {}

  depends_on = [azurerm_service_plan.diag_service_plan]
}

data "archive_file" "app_zip" {
  type        = "zip"
  excludes    = ["__pycache__", ".venv", "local.settings.json", ".funcignore"]
  source_dir  = "C:/Users/sinwi/Documents/terraformCloudCreate/AzureFinal/AzureFunctionApp"
  output_path = "C:/Users/sinwi/Documents/terraformCloudCreate/AzureFinal/tmp/AzureFunctionApp.zip"
}

resource "azurerm_role_assignment" "function_app_sql_contributor" {
  scope                = var.module_postgres_fs_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_linux_function_app.diag_app.identity.0.principal_id
}

resource "azurerm_role_assignment" "func_app_reader" {
  scope                = "subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = "Reader"
  principal_id         = azurerm_linux_function_app.diag_app.identity.0.principal_id

  depends_on = [
    azurerm_linux_function_app.diag_app,
    var.module_keyvault
  ]
}

resource "azurerm_role_assignment" "func_app_storage_contributor" {
  scope                = azurerm_storage_account.st.id
  role_definition_name = "Storage Blob Data Contributor"
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

  secret_permissions = ["Get", "List"]

  storage_permissions = ["Delete", "Get", "GetSAS", "List", "ListSAS", "Update"]

  depends_on = [
    azurerm_linux_function_app.diag_app,
    var.module_keyvault
  ]
}

# Data source to retrieve function keys
data "azurerm_function_app_host_keys" "func_app_keys" {
  name                = azurerm_linux_function_app.diag_app.name
  resource_group_name = azurerm_resource_group.diag.name
  depends_on = [azurerm_resource_group.diag,
  azurerm_linux_function_app.diag_app]
}


resource "azurerm_subnet" "func_app" {
  name                                          = lower("${var.subnet_prefix}-${random_pet.name_prefix.id}-${var.funcapp_subnet_name}")
  resource_group_name                           = var.module_vnet_resource_grp
  virtual_network_name                          = var.module_vnet_name
  address_prefixes                              = var.funcapp_subnet_address_prefix
  private_endpoint_network_policies             = false
  private_link_service_network_policies_enabled = false

  service_endpoints = ["Microsoft.KeyVault", "Microsoft.Web", "Microsoft.Storage"]

  delegation {
    name = "funcapp-delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }

  depends_on = [
    var.module_vnet
  ]
}

resource "azurerm_app_service_virtual_network_swift_connection" "swift_conncetion" {
  app_service_id = azurerm_linux_function_app.diag_app.id
  subnet_id      = azurerm_subnet.func_app.id

  depends_on = [
    azurerm_service_plan.diag_service_plan,
    azurerm_linux_function_app.diag_app,
    var.module_vnet
  ]
}
