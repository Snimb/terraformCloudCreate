/*
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tf-mgmt-project1"
    storage_account_name = "sttfstatesdev"
    container_name       = "terraformstates"
    key                  = "project1-state-"
  }
}
*/