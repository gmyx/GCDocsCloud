data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "GCDocs_KeyVault" {
  name                        = "GCDocs-Master-KeyVault"
  location                    = azurerm_resource_group.GCDOCS.location
  resource_group_name         = azurerm_resource_group.GCDOCS.name
  enabled_for_deployment = true
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  #soft_delete_enabled         = true
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "get",
    ]

    secret_permissions = [
      "get","set","delete","purge"
    ]

    storage_permissions = [
      "get",
    ]
  }

  #only good for testing, need a way to allow creating stuff without Allow
  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  tags = {
    environment = "Testing"
  }
}