resource azurerm_network_security_group NSG {
  count               = var.deploy ? 1 : 0
  name                = "${var.name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group.name
  dynamic "security_rule" {
    for_each = [for s in var.security_rules : {
      name                       = s.name
      priority                   = s.priority
      direction                  = s.direction
      access                     = s.access
      protocol                   = s.protocol
      source_port_ranges         = split(",", replace(s.source_port_ranges, "*", "0-65535"))
      destination_port_ranges    = split(",", replace(s.destination_port_ranges, "*", "0-65535"))
      source_address_prefix      = s.source_address_prefix
      destination_address_prefix = s.destination_address_prefix
      description                = s.description
    }]
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_ranges         = security_rule.value.source_port_ranges
      destination_port_ranges    = security_rule.value.destination_port_ranges
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
      description                = security_rule.value.description
    }
  }
  tags = var.tags
}

resource "azurerm_storage_account" "boot_diagnostic" {
  count                    = var.boot_diagnostic && var.deploy ? 1 : 0 # This implement an AND condition for OR use
  name                     = local.storageName
  resource_group_name      = var.resource_group.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# If public_ip is true then create resource. If not then do not create any
resource azurerm_public_ip VM-EXT-PubIP {
  count               = var.public_ip && var.deploy ? length(var.nic_ip_configuration.private_ip_address_allocation) : 0
  name                = "${var.name}-pip${count.index + 1}"
  location            = var.location
  resource_group_name = var.resource_group.name
  sku                 = "Standard"
  allocation_method   = "Static"
  tags                = var.tags
}

resource azurerm_network_interface NIC {
  count                         = var.deploy ? 1 : 0
  name                          = "${var.name}-nic1"
  location                      = var.location
  resource_group_name           = var.resource_group.name
  enable_ip_forwarding          = var.nic_enable_ip_forwarding
  enable_accelerated_networking = var.nic_enable_accelerated_networking
  dns_servers                   = var.dnsServers
  dynamic "ip_configuration" {
    for_each = var.nic_ip_configuration.private_ip_address_allocation
    content {
      name                          = "ipconfig${ip_configuration.key + 1}"
      subnet_id                     = data.azurerm_subnet.subnet.id
      private_ip_address            = var.nic_ip_configuration.private_ip_address[ip_configuration.key]
      private_ip_address_allocation = var.nic_ip_configuration.private_ip_address_allocation[ip_configuration.key]
      public_ip_address_id          = var.public_ip ? azurerm_public_ip.VM-EXT-PubIP[ip_configuration.key].id : ""
      primary                       = ip_configuration.key == 0 ? true : false
    }
  }
  tags = var.tags
}

resource azurerm_network_interface_security_group_association nic-nsg {
  count                     = var.deploy ? 1 : 0
  network_interface_id      = azurerm_network_interface.NIC[0].id
  network_security_group_id = azurerm_network_security_group.NSG[0].id
}

resource azurerm_windows_virtual_machine VM {
  count                 = var.deploy ? 1 : 0
  name                  = var.name
  depends_on            = [var.vm_depends_on]
  location              = var.location
  resource_group_name   = var.resource_group.name
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  computer_name         = var.name
  custom_data           = var.custom_data
  size                  = var.vm_size
  priority              = var.priority
  eviction_policy       = local.eviction_policy
  network_interface_ids = [azurerm_network_interface.NIC[0].id]
  availability_set_id   = var.availability_set_id
  license_type          = var.license_type == null ? null : var.license_type
  source_image_id       = var.source_image_id
  /*source_image_reference {
    publisher = var.storage_image_reference.publisher
    offer     = var.storage_image_reference.offer
    sku       = var.storage_image_reference.sku
    version   = var.storage_image_reference.version
  }*/
  dynamic "plan" {
    for_each = local.plan
    content {
      name      = local.plan[0].name
      product   = local.plan[0].product
      publisher = local.plan[0].publisher
    }
  }
  provision_vm_agent = true
  os_disk {
    name                 = "${var.name}-osdisk1"
    caching              = var.storage_os_disk.caching
    storage_account_type = var.os_managed_disk_type
    disk_size_gb         = var.storage_os_disk.disk_size_gb
  }

  dynamic "boot_diagnostics" {
    for_each = local.boot_diagnostic
    content {
      storage_account_uri = azurerm_storage_account.boot_diagnostic[0].primary_blob_endpoint
    }
  }
  dynamic "identity" {
    for_each = local.assign-identity
    content {
      type = "SystemAssigned"
    }
  }
  tags = var.tags
  lifecycle {
    ignore_changes = [
      # Ignore changes to username and password because it will require destroying and
      # recreating the VM and all associated resources. It is better handled within the VM post deployment.
      # This will prevent disastrous destruction in case someone plan a name and password change.
      admin_username,
      admin_password,
    ]
  }
}

resource azurerm_managed_disk data_disks {
  count = length(var.data_disk_sizes_gb) * ( var.deploy == true ? 1 : 0 )

  name                 = "${var.name}-datadisk${count.index + 1}"
  location             = var.location
  resource_group_name  = var.resource_group.name
  storage_account_type = var.data_managed_disk_type
  create_option        = "Empty"
  disk_size_gb         = var.data_disk_sizes_gb[count.index]
}

resource azurerm_virtual_machine_data_disk_attachment data_disks {
  count = length(var.data_disk_sizes_gb) * ( var.deploy == true ? 1 : 0 )

  managed_disk_id    = azurerm_managed_disk.data_disks[count.index].id
  virtual_machine_id = azurerm_windows_virtual_machine.VM[0].id
  lun                = count.index
  caching            = "ReadWrite"
}

#associate LB with primary nic
resource azurerm_network_interface_backend_address_pool_association PoolAssociation {
  count = length(var.load_balancer_backend_address_pools_ids)

  network_interface_id    = azurerm_network_interface.NIC.id
  ip_configuration_name   = azurerm_network_interface.NIC.ip_configuration[0].name
  backend_address_pool_id = var.load_balancer_backend_address_pools_ids[count.index]
}
