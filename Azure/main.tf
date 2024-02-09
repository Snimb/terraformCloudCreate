resource "azurerm_resource_group" "default" {
  name     = random_pet.name_prefix.id # Uses the generated random name for the resource group.
  location = var.location              # The location for the resource group.
}

# Generates a random password for use with the PostgreSQL server, enhancing security by avoiding hardcoded or weak passwords.
resource "random_password" "pass" {
  length           = 20
  special          = true
  override_special = "!#%+:=?@"
}
