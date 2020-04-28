resource "azurerm_public_ip" "PublicIP" {
  name                = "PublicIP-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}

resource "azurerm_lb" "LoadBalancer" {
  name                = "LoadBalancer-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                 = "PublicIP-${var.environment}"
    public_ip_address_id = azurerm_public_ip.PublicIP.id
  }
}