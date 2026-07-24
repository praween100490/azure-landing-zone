provider "azurerm" {
  features {}

  subscription_id = "b299f192-d573-4040-b542-2aff90a974b5"
}
data "azurerm_client_config" "current" {}