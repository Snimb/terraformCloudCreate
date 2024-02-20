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
  description = "Specifies the resource id of the virtual network"
  value       = azurerm_virtual_network.vnet.id
}
