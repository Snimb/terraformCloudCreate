/*# create azure storage account
resource "azurerm_storage_account" "st" {
  name                     = "st${var.storage_name}${local.environment}"
  resource_group_name      = azurerm_resource_group.default.name
  location                 = azurerm_resource_group.default.location
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
    azurerm_resource_group.default
  ]
}

# Create  storage account's `files share` using terraform
resource "azurerm_storage_share" "azure_storage" {
  name                 = var.storage_file_share_name
  storage_account_name = azurerm_storage_account.st.name
  quota                = 10
  depends_on = [
    azurerm_storage_account.st
  ]
}

# Create private DNS zone for blob storage account
resource "azurerm_private_dns_zone" "pdz_blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_virtual_network.vnet.resource_group_name

  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

# Create private virtual network link to prod vnet
resource "azurerm_private_dns_zone_virtual_network_link" "blob_pdz_vnet_link" {
  name                  = "privatelink_to_${azurerm_virtual_network.vnet.name}"
  resource_group_name   = azurerm_resource_group.default.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  private_dns_zone_name = azurerm_private_dns_zone.pdz_blob.name

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
  depends_on = [
    azurerm_resource_group.default,
    azurerm_virtual_network.vnet,
    azurerm_private_dns_zone.pdz_blob
  ]
}

# Create private endpoint for blob storage account
resource "azurerm_private_endpoint" "pe_blob" {
  name                = lower("${var.private_endpoint_prefix}-${azurerm_storage_account.st.name}")
  location            = azurerm_storage_account.st.location
  resource_group_name = azurerm_storage_account.st.resource_group_name
  subnet_id           = azurerm_subnet.jumpbox.id

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
}*/