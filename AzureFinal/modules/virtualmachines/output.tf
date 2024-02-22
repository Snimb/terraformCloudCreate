# Resource group:
output "resource_group_name" {
  value = azurerm_resource_group.vm.name # Outputs the name of the created resource group.
}

/*output "vm_public_ip_address" {
  value = azurerm_network_interface.vm_nic.ip_configuration[0].public_ip_address
  description = "The public IP address of the Virtual Machine."
}

output "vm_private_ip_address" {
  value = azurerm_network_interface.vm_nic.ip_configuration[0].private_ip_address
  description = "The private IP address of the Virtual Machine."
}*/

output "vm_id" {
  value = azurerm_linux_virtual_machine.mgmt_vm.id
  description = "The resource ID of the Virtual Machine."
}