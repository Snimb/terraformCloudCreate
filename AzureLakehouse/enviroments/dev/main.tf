module "vnet" {
  source                        = "../../modules/network"
  location                      = var.location
  vnet_address_space            = var.vnet_address_space
  private_subnet_address_prefix = var.private_subnet_address_prefix
  public_subnet_address_prefix  = var.public_subnet_address_prefix
}

module "lakehouse" {
  source   = "../../modules/lakehouse"
  location = var.location
}

module "databricks" {
  source   = "../../modules/databricks"
}