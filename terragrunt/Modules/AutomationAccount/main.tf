resource "azurerm_automation_account" "GCDOCS-DSC" {
  name                = "GCDOCS-DSC"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_name = "Basic"

    lifecycle {
    prevent_destroy = true
  }
}