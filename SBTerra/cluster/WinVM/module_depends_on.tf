/*
    Add the following line to the resource in this module that depends on the completion of external module components:

    vm_depends_on = [azurerm_subnet.vm1-sn, azurerm_virtual_network.vm1-vnet]

    This will force Terraform to wait until the dependant external resources are created before proceeding with the creation of the
    resource that contains the line above.

    This is a hack until Terraform officially support module depends_on.
*/

variable "vm_depends_on" {
  type    = any
  default = null
}