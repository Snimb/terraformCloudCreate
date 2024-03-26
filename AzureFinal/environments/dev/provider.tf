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
    azuread = {
      source  = "hashicorp/azuread"
      version = "~>2.0"
    }
    azapi = {
      source = "Azure/azapi"
    }
  }
}

provider "random" {}

provider "azuread" {
  # If different from ARM_* variables, specify client_id, client_secret, and tenant_id here
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azapi" {}
