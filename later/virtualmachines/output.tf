# Resource group:
output "resource_group_name" {
  value = azurerm_resource_group.vm.name # Outputs the name of the created resource group.
}

output "vm_public_ip_address" {
  value = azurerm_network_interface.vm_nic.ip_configuration[0].public_ip_address
  description = "The public IP address of the Virtual Machine."
}

output "vm_private_ip_address" {
  value = azurerm_network_interface.vm_nic.ip_configuration[0].private_ip_address
  description = "The private IP address of the Virtual Machine."
}

output "vm_id" {
  value = azurerm_linux_virtual_machine.mgmt_vm.id
  description = "The resource ID of the Virtual Machine."
}

output "vm_identity_principal_id" {
  value = azurerm_user_assigned_identity.default.principal_id
  description = "The principal ID of the Virtual Machine's user-assigned managed identity."
}

output "vm_identity_client_id" {
  value = azurerm_user_assigned_identity.default.client_id
  description = "The client ID of the Virtual Machine's user-assigned managed identity."
}