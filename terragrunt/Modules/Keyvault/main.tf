terraform {
  # Live modules pin exact Terraform version; generic modules let consumers pin the version.
  # The latest version of Terragrunt (v0.19.0 and above) requires Terraform 0.12.0 or above.
  required_version = "~> 0.12.17"

  # Live modules pin exact provider version; generic modules let consumers pin the version.
  required_providers {
    azurerm = {
      version = "~> 2.6"
    }
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "KeyVault" {
  name                        = "GCDocs-Master-KeyVault"
  location                    = var.location
  resource_group_name         = var.resource_group_name
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
      "get","list"
    ]

    secret_permissions = [
      "get","set","delete","purge","list"
    ]

    storage_permissions = [
      "get","list"
    ]
  }

  #only good for testing, need a way to allow creating stuff without Allow
  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  /*tags = {
    environment = var.environment
  }*/
}