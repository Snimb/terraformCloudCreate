terraform {
  required_version = ">=1.0" # Specifies the minimum Terraform version required for this configuration.

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm" # The Azure Resource Manager provider source location.
      version = "~>3.0"             # Specifies the version of the AzureRM provider to use.
    }
    random = {
      source  = "hashicorp/random" # The Random provider source location for generating random values.
      version = ">= 3.4.0"         # Specifies the version of the Random provider to use.
    }
  }
}

# provider "random" {}

provider "azurerm" {
  features {} # Required block for Azure provider, even if empty, to specify provider-specific features.
  subscription_id = var.sp-subscription-id
  tenant_id       = var.sp-tenant-id
  client_secret   = var.sp-client-secret
  client_id       = var.sp-client-id

}
