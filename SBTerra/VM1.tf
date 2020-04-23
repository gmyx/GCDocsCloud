/*

module "Test" {
  source = "./terraform-azurerm-basicwindowsvm-v2-master"

  name = "${var.cluster_name}-s1"
  resource_group_name = azurerm_resource_group.vm1.name
  admin_username = "opentext"
  admin_password = azurerm_key_vault_secret.VM1-Secret.value
  nic_subnetName = azurerm_subnet.vm1-sn.name
  nic_vnetName  = azurerm_virtual_network.vm1-vnet.name
  nic_resource_group_name = azurerm_resource_group.vm1.name
  vm_size = var.vm_size
  location = var.location

  #funky depends on
  vm_depends_on = [azurerm_subnet.vm1-sn, azurerm_virtual_network.vm1-vnet]
}*/