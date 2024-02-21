# Azure resource:
variable "diag_rg_name" {
  description = "Name of the resource group"
  type        = string
  default = "workspace"
}

variable "location" {}

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
