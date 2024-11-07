terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfmgmt-dev"
    storage_account_name = "storageacctfstatesdev"
    container_name       = "tfmgmtstates"
    key                  = "project-postgres-state-dev.tfstate"
  }
}