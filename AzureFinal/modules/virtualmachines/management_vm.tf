resource "azurerm_linux_virtual_machine" "mgmt_vm" {
  name                            = lower("${var.vm_prefix}-${var.vm_name}")
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
    # type         = "UserAssigned"
    # identity_ids = [var.module_user_assigned_identity_id]
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }
  # Custom Data for installing PostgreSQL client and fetching connection string from Key Vault
  custom_data = base64encode(data.template_file.init_script.rendered)
}

resource "azurerm_network_interface" "vm_nic" {
  name                = lower("${var.vm_prefix}-${var.vm_name}-nic")
  location            = azurerm_resource_group.vm.location
  resource_group_name = azurerm_resource_group.vm.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.module_jumpbox_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

data "template_file" "init_script" {
  template = file("${path.module}/init-vm-script.sh.tpl")

  vars = {
    key_vault_name = var.module_keyvault_name
    secret_names   = join(",", [for name in keys(var.module_secret_connection_string_names) : name])
    admin_username = var.vm_admin_username

  }
  depends_on = [ azurerm_role_assignment.vm_kv_secrets_user ]
}
    # client_id      = var.module_user_assigned_identity_client_id


resource "azurerm_role_assignment" "vm_kv_secrets_user" {
  scope                = var.module_keyvault_id
  role_definition_name = "Key Vault VM Secrets User"
  principal_id         = azurerm_linux_virtual_machine.mgmt_vm.identity.0.principal_id
depends_on = [ azurerm_linux_virtual_machine.mgmt_vm ]
}



/*resource "azurerm_virtual_machine_extension" "diag_vm" {
  name                 = "diag_vm-diagnostics-extension"
  virtual_machine_id   = azurerm_linux_virtual_machine.mgmt_vm.id
  publisher            = "Microsoft.Azure.Diagnostics"
  type                 = "LinuxDiagnostic"
  type_handler_version = "4.0" # Make sure to use a supported version for your VM's OS

  settings = <<SETTINGS
{
  "ladCfg": {
    "diagnosticMonitorConfiguration": {
      "metrics": {
        "resourceId": "${azurerm_linux_virtual_machine.mgmt_vm.id}"
      }
    }
  }
}
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
{
  "workspaceId": "${azurerm_log_analytics_workspace.workspace.workspace_id}",
  "workspaceKey": "${azurerm_log_analytics_workspace.workspace.primary_shared_key}"
}
PROTECTED_SETTINGS
}
*/
