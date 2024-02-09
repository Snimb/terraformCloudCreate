variable "name_prefix" {
  default     = "postgresqlfs" # Default prefix for resource names to ensure uniqueness.
  description = "Prefix of the resource name."
}

resource "random_pet" "name_prefix" {
  prefix = var.name_prefix # Generates a random name prefix to ensure resource names are unique.
  length = 1               # Specifies the number of words in the generated name.
}
