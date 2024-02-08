variable "name_prefix" {
  default     = "postgresqlfs" # Default prefix for resource names to ensure uniqueness.
  description = "Prefix of the resource name."
}

variable "location" {
  default     = "West Europe" # Default location for all resources.
  description = "Location of the resource - primary location."
}

# Variables for the provider block:
variable "subscription_id" {}
variable "tenant_id" {}
# variable "client_id" {}
# variable "client_secret" {}

# Recommended settings based on system resources.
variable "total_memory_mb" {
  description = "Total memory in MB for the PostgreSQL server"
  default     = 4096 # Example value, adjust as needed.
}

/*variable "total_memory_kb" {
  description = "Total memory in KB for the PostgreSQL server"
  default     = 4096 * 1024 # Converts the default value to KB. Adjust as needed.
}

variable "total_memory_8kb" {
  description = "Total memory in KB for the PostgreSQL server"
  default     = 4096 * 1024 / 8 # Converts the default value to KB. Adjust as needed.
}*/

variable "cpu_cores" {
  description = "Number of CPU cores for the PostgreSQL server"
  default     = 2 # Example value, adjust as needed.
}
