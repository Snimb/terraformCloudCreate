variable "rg_prefix" {
  type        = string
  default     = "rg"
  description = "Prefix of the resource group name that's combined with name of the resource group."
}

variable "vm_prefix" {
   type        = string
  default     = "vm"
  description = "Prefix of the virtual machine."
}