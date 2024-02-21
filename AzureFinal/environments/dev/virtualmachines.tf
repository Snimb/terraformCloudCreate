module "virtualmachines_dev" {
  source              = "../../modules/virtualmachines"
  location            = var.location
  vm_size             = "Standard_DS1_v2"
  storage_account_type = ""
  image_publisher = ""
  admin_ssh_key_username = ""
  image_sku = ""
  vm_admin_username = ""
  image_offer = ""
  admin_public_key_path = ""
}