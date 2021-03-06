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
  name         = "${var.cluster_name}-${var.role}-Secret"
  value        = var.admin_secret
  key_vault_id = var.keyvault_id

  tags = {
    environment = var.environment
  }
}

resource "azurerm_network_interface_nat_rule_association" "NatRule" {
  network_interface_id  = module.WinVM.Nic0.id
  ip_configuration_name = module.WinVM.Nic0.ip_configuration[0].name
  nat_rule_id           = var.lb_nat_rule_id

  depends_on = [module.WinVM]
}

data "azurerm_shared_image" "packer-image" {
  name                = "CS16.2.11"
  gallery_name        = "GCdocsImages"
  resource_group_name = "GCDOCS-dev-rg"
}

data "azurerm_resource_group" "GCDOCS" {
  name     = var.resource_group_name
  location = var.location
}

module "WinVM" {
  #source = "./terraform-azurerm-basicwindowsvm-v2"
  source = "./terraform-azurerm_windows_virtual_machine"

  name = "${var.cluster_name}-${var.role}"
  resource_group = data.azurerm_resource_group.GCDOCS #var.resource_group #_name
  admin_username = "opentext"
  admin_password = azurerm_key_vault_secret.VM-Secret.value
  nic_subnetName = var.subnet_name
  nic_vnetName  = var.vnet_name
  nic_resource_group_name = data.azurerm_resource_group.GCDOCS.name
  vm_size = var.size
  location = var.location
  load_balancer_backend_address_pools_ids = var.load_balancer_backend_address_pools_ids
  #data_disk_create_option = "FromImage"
  #data_disk_sizes_gb = [80,40]
  #data_disk_image_reference_ids = ["/subscriptions/98d18bb7-62b4-4fb6-b35b-9416f12eb2cc/resourceGroups/GCDOCS-DEV-RG/providers/Microsoft.Compute/disks/datadisk-1","/subscriptions/98d18bb7-62b4-4fb6-b35b-9416f12eb2cc/resourceGroups/GCDOCS-DEV-RG/providers/Microsoft.Compute/disks/datadisk-2"]

  source_image_id = data.azurerm_shared_image.packer-image.id
  /*storage_image_reference = {
    publisher = "GCDocsImages"
    offer     = "GB16_2_11"
    sku       = "GB16_2_11"
    version   = "0.1.0"
  }*/

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
      name                       = "RDPIn"
      description                = "Allow RDP in"
      access                     = "Allow"
      priority                   = "199"
      protocol                   = "*"
      direction                  = "Inbound"
      source_port_ranges         = "*"
      source_address_prefix      = "*"
      destination_port_ranges    = "3389"
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
    },
    {
      name                       = "RDPOut"
      description                = "Allow RDP Out"
      access                     = "Allow"
      priority                   = "299"
      protocol                   = "*"
      direction                  = "Outbound"
      source_port_ranges         = "*"
      source_address_prefix      = "*"
      destination_port_ranges    = "3389"
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