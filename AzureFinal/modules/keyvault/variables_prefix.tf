variable "rg_prefix" {
  type        = string
  default     = "rg"
  description = "Prefix of the resource group name that's combined with name of the resource group."
}

variable "kv_prefix" {
  type        = string
  default     = "kv"
  description = "Prefix of the Azure key vault."
}

variable "private_endpoint_prefix" {
  type        = string
  default     = "pe"
  description = "Prefix of the private endpoint."
}
