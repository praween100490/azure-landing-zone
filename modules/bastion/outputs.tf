output "bastion_id" {
  value = azurerm_bastion_host.this.id
}

output "public_ip_id" {
  value = azurerm_public_ip.this.id
}