module "resource_group" {
  source = "../../modules/resource_group"

  resource_group_name = "dev-rg"
  location            = "Central India"
}
module "virtual_network" {
  source = "../../modules/virtual_network"

  vnet_name           = "dev-vnet"
  resource_group_name = module.resource_group.resource_group_name
  location            = "Central India"
  address_space       = ["10.0.0.0/16"]
}
module "hub_virtual_network" {
  source = "../../modules/virtual_network"

  vnet_name           = "hub-vnet"
  resource_group_name = module.resource_group.resource_group_name
  location            = "Central India"
  address_space       = ["10.1.0.0/16"]
}
module "subnet" {
  source = "../../modules/subnet"

  subnet_name          = "web-subnet"
  resource_group_name  = module.resource_group.resource_group_name
  virtual_network_name = module.virtual_network.vnet_name
  address_prefixes     = ["10.0.1.0/24"]
}
module "network_security_group" {
  source = "../../modules/network_security_group"

  nsg_name            = "web-nsg"
  resource_group_name = module.resource_group.resource_group_name
  location            = "Central India"
}
module "storage_account" {
  source = "../../modules/storage_account"

  storage_account_name = var.storage_account_name
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
}
module "key_vault" {
  source = "../../modules/key_vault"

  key_vault_name      = var.key_vault_name
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  tenant_id           = data.azurerm_client_config.current.tenant_id
}
module "log_analytics" {
  source = "../../modules/log_analytics"

  log_analytics_workspace_name = var.log_analytics_workspace_name
  resource_group_name          = module.resource_group.resource_group_name
  location                     = module.resource_group.resource_group_location
}
module "virtual_machine" {
  source = "../../modules/virtual_machine"

  virtual_machine_name = "dev-vm"
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location

  virtual_machine_size = "Standard_D2s_v3"
  admin_username       = "azureuser"

  public_ip_name         = "dev-vm-pip"
  network_interface_name = "dev-vm-nic"

  subnet_id = module.subnet.subnet_id

  public_key_path = "~/.ssh/id_ed25519.pub"
}
module "network_security_group_association" {
  source = "../../modules/network_security_group_association"

  subnet_id = module.subnet.subnet_id

  network_security_group_id = module.network_security_group.nsg_id
}
module "bastion_subnet" {
  source = "../../modules/subnet"

  subnet_name          = "AzureBastionSubnet"
  resource_group_name  = module.resource_group.resource_group_name
  virtual_network_name = module.virtual_network.vnet_name
  address_prefixes     = ["10.0.2.0/26"]
}
module "bastion" {
  source = "../../modules/bastion"

  bastion_name        = "dev-bastion"
  public_ip_name      = "dev-bastion-pip"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location

  bastion_subnet_id = module.bastion_subnet.subnet_id
}
module "dev_to_hub_peering" {
  source = "../../modules/vnet_peering"

  peering_name              = "dev-to-hub"
  resource_group_name       = module.resource_group.resource_group_name
  virtual_network_name      = module.virtual_network.vnet_name
  remote_virtual_network_id = module.hub_virtual_network.vnet_id
}
module "hub_to_dev_peering" {
  source = "../../modules/vnet_peering"

  peering_name              = "hub-to-dev"
  resource_group_name       = module.resource_group.resource_group_name
  virtual_network_name      = module.hub_virtual_network.vnet_name
  remote_virtual_network_id = module.virtual_network.vnet_id
}