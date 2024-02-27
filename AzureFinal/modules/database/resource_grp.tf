# Create the resource group
resource "azurerm_resource_group" "db" {
  name     = lower("${var.rg_prefix}-${random_pet.name_prefix.id}-${var.db_rg_name}-${local.environment}")
  location = var.location
  tags = merge(local.default_tags,
    {
      "CreatedBy" = "sinwi"
  })
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

locals {
  default_tags = merge(var.default_tags, { "Environment" = "${terraform.workspace}" })
  environment  = terraform.workspace != "default" ? terraform.workspace : ""
}

resource "random_pet" "name_prefix" {
  prefix = var.name_prefix # Generates a random name prefix to ensure resource names are unique.
  length = 1               # Specifies the number of words in the generated name.
}

variable "name_prefix" {
  default     = "azure" # Default prefix for resource names to ensure uniqueness.
  description = "Prefix of the resource name."
}

# Lock the resource group
/*resource "azurerm_management_lock" "db" {
  name       = "CanNotDelete"
  scope      = azurerm_resource_group.db.id
  lock_level = "CanNotDelete"
  notes      = "This resource group can not be deleted - lock set by Terraform"
  depends_on = [
    azurerm_resource_group.db,
  ]
}*/
