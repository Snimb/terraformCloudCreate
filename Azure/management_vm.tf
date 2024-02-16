/*
resource "azurerm_linux_virtual_machine" "mag_vm" {
  name                  = "${random_pet.name_prefix.id}-vm"
  resource_group_name   = azurerm_resource_group.default.name
  location              = azurerm_resource_group.default.location
  computer_name         = "Management VM"
  size                  = "Standard_DS1_v2"
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.vm_nic.id]
  admin_ssh_key {
    username   = "azureuser"
    public_key = file("C:\\Users\\sinwi\\.ssh\\id_rsa.pub")
  }
  custom_data = filebase64("shellscripts/init-vm-script.sh") # Optional, use if you have a cloud-init script
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"
    version   = "latest"
  }
  admin_password                  = data.azurerm_key_vault_secret.secret_1.value
  disable_password_authentication = true

  depends_on = [azurerm_key_vault_secret.secret_1]
}

resource "azurerm_network_interface" "vm_nic" {
  name                = "${random_pet.name_prefix.id}-nic"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.jumpbox.id
    private_ip_address_allocation = "Dynamic"
  }
}
*/

resource "azurerm_linux_virtual_machine" "mgmt_vm" {
  name                            = "${random_pet.name_prefix.id}-vm"
  resource_group_name             = azurerm_resource_group.default.name
  location                        = azurerm_resource_group.default.location
  size                            = "Standard_DS1_v2"
  admin_username                  = var.admin_username
  network_interface_ids           = [azurerm_network_interface.vm_nic.id]
  disable_password_authentication = true
  admin_ssh_key {
    username   = "azureuser"
    public_key = file("C:\\Users\\sinwi\\.ssh\\id_rsa.pub") # Ensure this variable is defined in your variables file
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"
    version   = "latest"
  }

  # Custom Data for installing PostgreSQL client and fetching connection string from Key Vault
  custom_data = base64encode(data.template_file.init_script.rendered)
}

resource "azurerm_network_interface" "vm_nic" {
  name                = "${random_pet.name_prefix.id}-nic"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.jumpbox.id
    private_ip_address_allocation = "Dynamic"
  }
}

data "template_file" "init_script" {
  template = file("${path.module}/init-vm-script.sh.tpl")

  vars = {
    key_vault_name = azurerm_key_vault.kv.name
    secret_name    = azurerm_key_vault_secret.secret_3.name
  }
}
