output "virtual_machine_id" {
  value = azurerm_linux_virtual_machine.this.id
}
output "network_interface_ids" {
    value = azurerm_network_interface.this.id
  
}
output "public_ip_address_id" {
    value = azurerm_public_ip.this.id
  
}