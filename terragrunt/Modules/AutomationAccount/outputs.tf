output "automation_account_name" {
  value = azurerm_automation_account.GCDOCS-DSC.name
}

output "dsc_server_endpoint" {
  value = azurerm_automation_account.GCDOCS-DSC.dsc_server_endpoint
}

output "dsc_primary_access_key" {
  value = azurerm_automation_account.GCDOCS-DSC.dsc_primary_access_key
}

output "dsc_secondary_access_key" {
  value = azurerm_automation_account.GCDOCS-DSC.dsc_secondary_access_key
}