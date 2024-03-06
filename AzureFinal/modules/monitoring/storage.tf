# create azure storage account
resource "azurerm_storage_account" "st" {
  name                     = lower(substr(replace("${var.storage_name}${random_pet.name_prefix.id}", "-", ""), 0, 24))
  resource_group_name      = azurerm_resource_group.diag.name
  location                 = azurerm_resource_group.diag.location
  access_tier              = var.storage_access_tier
  account_kind             = var.storage_account_kind
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_replication_type
  is_hns_enabled           = var.storage_is_hns_enabled

  network_rules {
    default_action             = (length(var.storage_ip_rules) + length(var.storage_virtual_network_subnet_ids)) > 0 ? "Deny" : var.storage_default_action
    ip_rules                   = var.storage_ip_rules
    virtual_network_subnet_ids = var.storage_virtual_network_subnet_ids
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_resource_group.diag
  ]
}

# Create private DNS zone for blob storage account
resource "azurerm_private_dns_zone" "pdz_blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.module_vnet_resource_grp

  depends_on = [
    var.module_vnet
  ]
}

# Create private virtual network link to prod vnet
resource "azurerm_private_dns_zone_virtual_network_link" "blob_pdz_vnet_link" {
  name                  = "privatelink_to_${var.module_vnet_name}"
  resource_group_name   = var.module_vnet_resource_grp
  virtual_network_id    = var.module_vnet_id
  private_dns_zone_name = azurerm_private_dns_zone.pdz_blob.name

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
  depends_on = [
    var.module_vnet_resource_grp,
    var.module_vnet_id,
    azurerm_private_dns_zone.pdz_blob
  ]
}

# Create private endpoint for blob storage account
resource "azurerm_private_endpoint" "pe_blob" {
  name                = lower("${var.private_endpoint_prefix}-${azurerm_storage_account.st.name}")
  location            = azurerm_storage_account.st.location
  resource_group_name = azurerm_storage_account.st.resource_group_name
  subnet_id           = var.module_subnet_jumpbox_id

  private_service_connection {
    name                           = lower("${var.private_endpoint_prefix}-${azurerm_storage_account.st.name}")
    private_connection_resource_id = azurerm_storage_account.st.id
    is_manual_connection           = false
    subresource_names              = var.pe_blob_subresource_names
  }

  private_dns_zone_group {
    name                 = var.pe_blob_private_dns_zone_group_name
    private_dns_zone_ids = [azurerm_private_dns_zone.pdz_blob.id]
  }

  depends_on = [
    azurerm_storage_account.st,
    azurerm_private_dns_zone.pdz_blob
  ]
}

# Storage Management Policy for Storage Account
resource "azurerm_storage_management_policy" "st_mgmt_policy" {
  storage_account_id = azurerm_storage_account.st.id

  rule {
    name    = "retention-policy"
    enabled = true
    filters {
      blob_types   = ["blockBlob"]
      prefix_match = ["logs/", "metrics/"]
    }
    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = var.storage_account_retention_days
      }
      snapshot {
        delete_after_days_since_creation_greater_than = var.storage_account_retention_days
      }
    }
  }
}

# Create key vault secret for storage account accesskey
resource "azurerm_key_vault_secret" "storage_access_key" {
  name         = "storage-account-accesskey"
  value        = azurerm_storage_account.st.primary_access_key
  key_vault_id = var.module_keyvault_id
  tags         = {}
  depends_on = [
    var.module_keyvault,
    azurerm_storage_account.st
  ]
}



resource "azurerm_storage_container" "func_app_container" {
  name                  = "appfunctionblobstorage" 
  storage_account_name  = azurerm_storage_account.st.name
  container_access_type = "private"
}

# Store Storage Account Connection String as a secret in Azure Key Vault
resource "azurerm_key_vault_secret" "storage_conn_str" {
  name         = "storageConnectionString"
  value        = azurerm_storage_account.st.primary_connection_string
  key_vault_id = var.module_keyvault_id
}



/*resource "azurerm_key_vault_secret" "funcapp_blob_url" {
  name         = "FuncAppBlobUrl"
  value        = "https://${azurerm_storage_account.st.name}.blob.core.windows.net/${azurerm_storage_container.func_app_container.name}/${azurerm_storage_blob.app_blob.name}?${var.blob_container_sas_token}"
  key_vault_id = azurerm_key_vault.kv.id
  depends_on = [ var.module_keyvault,
    azurerm_storage_account_blob_container_sas.func_app_container_sas ]
}

*/

/*data "azurerm_storage_account_blob_container_sas" "func_app_container_sas" {
  connection_string = azurerm_storage_account.st.primary_connection_string
  container_name    = azurerm_storage_container.func_app_container.name
  start             = formatdate("YYYY-MM-DD'T'hh:mm:00Z", timeadd(timestamp(), "-1h"))
  expiry            = formatdate("YYYY-MM-DD'T'hh:mm:00Z", timeadd(timestamp(), "24h"))
  https_only        = true

  # ip_address = "168.1.5.65"

  permissions {
    read   = true
    add    = true
    create = false
    write  = false
    delete = true
    list   = true
  }

  cache_control       = "max-age=5"
  content_disposition = "inline"
  content_encoding    = "deflate"
  content_language    = "en-US"
  content_type        = "application/json"
  depends_on = [ azurerm_storage_account.st, 
  azurerm_storage_container.func_app_container,
  ]
}

resource "azurerm_key_vault_secret" "funcapp_blob_url" {
  name         = "FuncAppBlobUrl"
  value        = "https://${azurerm_storage_account.st.name}.blob.core.windows.net/${azurerm_storage_container.func_app_container.name}/${azurerm_storage_blob.app_blob.name}?${azurerm_storage_account_blob_container_sas.func_app_container_sas.sas}"
  key_vault_id = azurerm_key_vault.kv.id
  depends_on = [ var.module_keyvault,
    azurerm_storage_account_blob_container_sas.func_app_container_sas ]
}
*/