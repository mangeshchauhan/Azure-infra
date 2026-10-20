output "resource_group_name" {
  description = "Created resource group name."
  value       = azurerm_resource_group.main.name
}

output "virtual_network_name" {
  description = "Created virtual network name."
  value       = azurerm_virtual_network.main.name
}

output "subnet_ids" {
  description = "IDs of the VM and secondary subnets."
  value = {
    vm        = azurerm_subnet.vm.id
    secondary = azurerm_subnet.secondary.id
  }
}

output "vm_name" {
  description = "Created virtual machine name."
  value       = azurerm_linux_virtual_machine.main.name
}

output "vm_public_ip" {
  description = "Public IP address of the virtual machine."
  value       = azurerm_public_ip.vm.ip_address
}