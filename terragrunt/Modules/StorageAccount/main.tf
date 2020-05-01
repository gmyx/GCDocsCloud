resource "azurerm_storage_account" "example" {
  name                     = "gcdocsstorageaccount${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}