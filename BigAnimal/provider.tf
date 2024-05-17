terraform {
  required_providers {
    biganimal = {
      source  = "EnterpriseDB/biganimal"
      version = "0.9.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
  }
}

provider "biganimal" {
  # Configuration options
  ba_bearer_token = "<redacted>" // See Getting an API Token section for details
  ba_access_key = "<redacted>" // See Getting an Access Key section for details
}

resource "biganimal_azure_connection" "project_azure_conn" {
  project_id      = var.project_id
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}