/*resource "azurerm_public_ip" "PublicIP" {
  name                = "PublicIP-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}*/

resource "azurerm_lb" "LoadBalancer" {
  name                = "LoadBalancer-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  /*frontend_ip_configuration {
    name                 = "PublicIP-${var.environment}"
    public_ip_address_id = azurerm_public_ip.PublicIP.id
  }*/

  frontend_ip_configuration {
    name = "PrivateIP-${var.environment}"
    subnet_id = var.subnet_id
  }
}

resource "azurerm_lb_backend_address_pool" "BAP" {
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.LoadBalancer.id
  name                = "BackEndAddressPool"
}