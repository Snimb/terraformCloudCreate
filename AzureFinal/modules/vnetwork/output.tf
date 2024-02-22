# Resource group:
output "resource_group_name" {
  value = azurerm_resource_group.vnet.name # Outputs the name of the created resource group.
}

# Virtual network:
output "vnet_name" {
  description = "Specifies the name of the virtual network"
  value       = azurerm_virtual_network.vnet.name
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
  description = "Virtual Network ID"
}

output "vnet" {
  value = azurerm_virtual_network.vnet
  description = "Virtual Network"
}

output "subnet_jumpbox_id" {
  value = azurerm_subnet.jumpbox.id
  description = "Jumpbox Subnet ID"
}

output "subnet_bastion_id" {
  value = azurerm_subnet.hub_bastion.id
  description = "Bastion Subnet ID"
}

output "nsg_id" {
  value = azurerm_network_security_group.default.id
}
