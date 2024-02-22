# Create the resource group
resource "azurerm_resource_group" "diag" {
  name     = lower("${var.rg_prefix}-${var.diag_rg_name}-${local.environment}")
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

# Lock the resource group
/*resource "azurerm_management_lock" "diag" {
  name       = "CanNotDelete"
  scope      = azurerm_resource_group.diag.id
  lock_level = "CanNotDelete"
  notes      = "This resource group can not be deleted - lock set by Terraform"
  depends_on = [
    azurerm_resource_group.diag,
  ]
}*/