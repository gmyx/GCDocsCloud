/*
  This file contains objects that are common to all clusters
*/

resource "azurerm_resource_group" "GCDOCS" {
  name     = "GCDOCS-rg"
  location = var.location
}

resource "azurerm_virtual_network" "GCDOCS-vnet" {
  name                = "GCDOCS-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.GCDOCS.location
  resource_group_name = azurerm_resource_group.GCDOCS.name
}