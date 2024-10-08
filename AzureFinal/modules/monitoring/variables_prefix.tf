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

variable "network_watcher_prefix" {
  type        = string
  default     = "nw"
  description = "Prefix of the Network Watcher resource."
}

variable "private_endpoint_prefix" {
  type        = string
  default     = "pe"
  description = "Prefix of the private endpoint."
}

variable "subnet_prefix" {
  type        = string
  default     = "snet"
  description = "Prefix of the Subnet name."
}