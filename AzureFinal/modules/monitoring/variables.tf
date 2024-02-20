# Azure resource:
variable "diag_rg_name" {
  description = "Name of the resource group"
  type        = string
}

# Tags:
variable "default_tags" {
  type = map(any)
  default = {
    "Project"   = "Project-postgres"
    "Owner"     = "sinwi"
    "CreatedBy" = "sinwi"
  }
}

# Location:
variable "location" {
  description = "Location of the resource - primary location."
  type        = string
}

# Variables for the provider block:
variable "sp-subscription-id" {
  description = "Id of the azure subscription where all resources will be created"
  type        = string
  sensitive   = true

}

variable "sp-tenant-id" {
  description = "Tenant Id of the azure account."
  type        = string
  sensitive   = true

}

variable "sp-client-id" {
  description = "Client Id of A Service Principal or Azure Active Directory application registration used for provisioning azure resources."
  type        = string
  sensitive   = true

}

variable "sp-client-secret" {
  description = "Secret of A Service Principal or Azure Active Directory application registration used for provisioning azure resources."
  type        = string
  sensitive   = true
}

### LOG ANALYTICS ###
variable "log_analytics_workspace_sku" {
  description = "(Optional) Specifies the sku of the log analytics workspace"
  type        = string
  default     = "PerGB2018"
}

variable "solution_plan_map" {
  description = "(Required) Specifies solutions to deploy to log analytics workspace"
  type        = map(any)
  default = {
    ContainerInsight = {
      product   = "Microsoft.ContainerService/ContainerInsights"
      publisher = "Microsoft"
    }
  }
}

variable "log_analytics_retention_days" {
  description = " (Optional) Specifies the workspace data retention in days. Range between 31 and 730."
  type        = number
}

variable "log_analytics_workspace_name" {
  description = "(Required) Specifies the name of the log analytics workspace"
  type        = string
  default     = "log-analytics"
}
