resource "azurerm_linux_virtual_machine" "mgmt_vm" {
  name                            = lower("${random_pet.name_prefix.id}-vm")
  resource_group_name             = azurerm_resource_group.default.name
  location                        = azurerm_resource_group.default.location
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
    # type         = "SystemAssigned, UserAssigned"
    # identity_ids = [azurerm_user_assigned_identity.default.id]
    type = "SystemAssigned"

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
  name                = lower("${random_pet.name_prefix.id}-nic")
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.jumpbox.id
    private_ip_address_allocation = "Dynamic"
  }
}

data "template_file" "init_script" {
  template = file("${path.module}/shellscripts/init-vm-script.sh.tpl")

  vars = {
    key_vault_name = azurerm_key_vault.kv.name
    secret_name    = azurerm_key_vault_secret.secret_3.name

  }
  depends_on = [ azurerm_role_assignment.vm_kv_secrets_user ]
}

# client_id      = azurerm_user_assigned_identity.default.client_id

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
