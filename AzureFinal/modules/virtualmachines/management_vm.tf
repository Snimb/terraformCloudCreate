resource "azurerm_linux_virtual_machine" "mgmt_vm" {
  name                            = lower("${var.vm_prefix}-${random_pet.name_prefix.id}-${var.vm_name}")
  resource_group_name             = azurerm_resource_group.vm.name
  location                        = azurerm_resource_group.vm.location
  size                            = var.vm_size
  admin_username                  = var.vm_admin_username
  network_interface_ids           = [azurerm_network_interface.vm_nic.id]
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_ssh_key_username
    public_key = file(var.admin_public_key_path) # Ensure this variable is defined in your variables file
  }

  os_disk {
    caching              = var.os_disk_caching
    storage_account_type = var.storage_account_type
  }

  identity {
    type = "SystemAssigned"
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }
}

resource "azurerm_network_interface" "vm_nic" {
  name                = lower("${var.vm_prefix}-${random_pet.name_prefix.id}-${var.vm_name}-nic")
  location            = azurerm_resource_group.vm.location
  resource_group_name = azurerm_resource_group.vm.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.module_jumpbox_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine_extension" "init_script" {
  name                 = "initScriptExtension"
  virtual_machine_id   = azurerm_linux_virtual_machine.mgmt_vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  settings = <<-SETTINGS
    {
      "fileUris": ["${var.sas_token}"],
      "commandToExecute": "sudo bash init-vm-script.sh '${var.vm_admin_username}' '${var.module_keyvault_name}' '${var.module_secret_connection_string_names[0]}' '${var.module_postgresql_configurations["azure.extensions"]}'"
    }
  SETTINGS

  depends_on = [azurerm_key_vault_access_policy.vm_access_policy,
    azurerm_role_assignment.vm_reader,
  ]
}

resource "azurerm_key_vault_access_policy" "vm_access_policy" {
  key_vault_id = var.module_keyvault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id # Your Azure tenant ID
  object_id    = azurerm_linux_virtual_machine.mgmt_vm.identity.0.principal_id

  key_permissions = ["Get", "List"]

  secret_permissions = ["Get", "List"]

  certificate_permissions = ["Get", "List"]

  depends_on = [
    azurerm_linux_virtual_machine.mgmt_vm,
    var.module_keyvault,
  ]
}

resource "azurerm_role_assignment" "vm_reader" {
  scope                = "subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = "Reader"
  principal_id         = azurerm_linux_virtual_machine.mgmt_vm.identity.0.principal_id
  depends_on = [
    azurerm_linux_virtual_machine.mgmt_vm,
    var.module_keyvault
  ]
}

resource "azurerm_monitor_diagnostic_setting" "diag_mgmt_vm" {
  name                       = lower("${var.vm_prefix}-${random_pet.name_prefix.id}-${var.vm_name}")
  target_resource_id         = azurerm_linux_virtual_machine.mgmt_vm.id
  log_analytics_workspace_id = var.module_log_analytics_workspace_id
  storage_account_id         = var.module_storage_account_id

  enabled_log {
    category_group = "allLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }

  depends_on = [
    var.module_keyvault,
    var.module_log_analytics_workspace_object,
  ]
}