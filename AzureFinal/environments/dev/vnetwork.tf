module "vnetwork_dev" {
  source                              = "../../modules/vnetwork"
  location                            = var.location
  vnet_name                           = lower("${var.vnet_prefix}-${var.vnet_name}-${local.environment}")
  vnet_address_space                  = var.vnet_address_space
  jumpbox_subnet_address_prefix       = var.jumpbox_subnet_address_prefix
  hub_bastion_subnet_address_prefixes = var.hub_bastion_subnet_address_prefixes
}
