variable "rg_prefix" {
  type        = string
  default     = "rg"
  description = "Prefix of the resource group name that's combined with name of the resource group."
}

variable "log_analytics_workspace_prefix" {
  type        = string
  default     = "workspace"
  description = "Prefix of the log analytics workspace prefix resource."
}

variable "diag_prefix" {
  type        = string
  default     = "diag"
  description = "Prefix of the Diagnostic Settings resource."
}