resource "azurerm_public_ip" "this" {
  name = var.public_ip_name
  resource_group_name = var.resource_group_name
  location = var.location
  allocation_method = "Static"
  sku = "Standard"
}
resource "azurerm_network_interface" "this" {
    name = var.network_interface_name
    resource_group_name = var.resource_group_name
    location = var.location
    ip_configuration {
      name = "internal"
      subnet_id = var.subnet_id
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id = azurerm_public_ip.this.id

    }
}
resource "azurerm_linux_virtual_machine" "this" {
    name = var.virtual_machine_name
    resource_group_name = var.resource_group_name
    location = var.location
    size = var.virtual_machine_size
    admin_username = var.admin_username
    network_interface_ids = [azurerm_network_interface.this.id]
    disable_password_authentication = true
    admin_ssh_key {
        
      username = var.admin_username
      public_key = file(var.public_key_path)
    }
    os_disk {
      caching = "ReadWrite"
      storage_account_type = "Standard_LRS"
    }
    source_image_reference {
      publisher = "Canonical"
      offer = "0001-com-ubuntu-server-jammy"
      sku = "22_04-lts"
      version = "latest"
    }
  
}