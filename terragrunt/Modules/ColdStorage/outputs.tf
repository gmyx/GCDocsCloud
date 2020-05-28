output "coldstorage_id" {
  value = azurerm_storage_account.gcdocsinstallers.id
}

output "coldstorage_name" {
  value = azurerm_storage_account.gcdocsinstallers.name
}

output "primary_access_key" {
  sensitive = true
  value = azurerm_storage_account.gcdocsinstallers.primary_access_key
}

output "primary_file_endpoint" {
  value = azurerm_storage_account.gcdocsinstallers.primary_file_endpoint
}