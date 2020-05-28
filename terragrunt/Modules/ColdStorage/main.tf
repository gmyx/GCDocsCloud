#note: the name of this resource is referenced in Intrastructure/{env}/ColdStorage -> terraform -> Before_hook
resource "azurerm_storage_account" "gcdocsinstallers" {
  name                     = var.storage_account_name
  location                 = var.location
  resource_group_name      = var.resource_group_name
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Cool"

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_storage_share" "coldshare" {
  name                 = var.storage_share_name
  storage_account_name = azurerm_storage_account.gcdocsinstallers.name
  quota                = 10

  lifecycle {
    prevent_destroy = true
  }
}

#if I could include the installers to upload, I would.