variable "rg_prefix" {
  type        = string
  default     = "rg"
  description = "Prefix of the resource group name that's combined with name of the resource group."
}

variable "subnet_prefix" {
  type        = string
  default     = "snet"
  description = "Prefix of the Subnet name."
}

variable "psql_prefix" {
  type        = string
  default     = "psql"
  description = "Prefix of the PostgreSQL server name that's combined with name of the PostgreSQL server."
}

variable "pdz_prefix" {
  type        = string
  default     = "pdz"
  description = "Prefix of the private DNS zone name."
}

variable "nsg_prefix" {
  type        = string
  default     = "nsg"
  description = "Prefix of the network security group name."
}