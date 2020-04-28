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


resource "azurerm_key_vault_secret" "VM-Secret" {
  name         = "VM1-Secret"
  value        = var.admin_secret
  key_vault_id = var.keyvault_id

  tags = {
    environment = var.environment
  }
}

module "WinVM" {
  source = "./terraform-azurerm-basicwindowsvm-v2-master"

  name = "${var.cluster_name}-${var.role}"
  resource_group_name = var.resource_group_name
  admin_username = "opentext"
  admin_password = azurerm_key_vault_secret.VM-Secret.value
  nic_subnetName = var.subnet_name
  nic_vnetName  = var.vnet_name
  nic_resource_group_name = var.resource_group_name
  vm_size = var.size
  location = var.location

  security_rules = [
    {
      name                       = "HTTPIn"
      description                = "Allow HTTP in"
      access                     = "Allow"
      priority                   = "100"
      protocol                   = "*"
      direction                  = "Inbound"
      source_port_ranges         = "*"
      source_address_prefix      = "*"
      destination_port_ranges    = "80"
      destination_address_prefix = "*"
    },
    {
      name                       = "HTTPSIn"
      description                = "Allow HTTPS in"
      access                     = "Allow"
      priority                   = "101"
      protocol                   = "*"
      direction                  = "Inbound"
      source_port_ranges         = "*"
      source_address_prefix      = "*"
      destination_port_ranges    = "443"
      destination_address_prefix = "*"
    },
    {
      name                       = "HTTPOut"
      description                = "Allow HTTP out"
      access                     = "Allow"
      priority                   = "200"
      protocol                   = "*"
      direction                  = "Outbound"
      source_port_ranges         = "*"
      source_address_prefix      = "*"
      destination_port_ranges    = "80"
      destination_address_prefix = "*"
    },
    {
      name                       = "HTTPSOut"
      description                = "Allow HTTPS out"
      access                     = "Allow"
      priority                   = "201"
      protocol                   = "*"
      direction                  = "Outbound"
      source_port_ranges         = "*"
      source_address_prefix      = "*"
      destination_port_ranges    = "443"
      destination_address_prefix = "*"
    }
  ]

  shutdownConfig = {
    autoShutdownStatus = "Enabled"
    autoShutdownTime = "16:00"
    autoShutdownTimeZone = "Eastern Standard Time"
    autoShutdownNotificationStatus = "Disabled"
  }
}