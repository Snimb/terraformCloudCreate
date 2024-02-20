module "network" {
  source = "/../modules/network"
  
  // Variables specific to the dev environment
  resource_group_name = "rg-dev"
  location            = "eastus"
  vnet_name           = "dev-vnet"
}
