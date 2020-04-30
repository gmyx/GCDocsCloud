/*output "PublicIP" {
  value = azurerm_public_ip.PublicIP.ip_address
}*/

output "LoadBalancer_ID" {
  value = azurerm_lb.LoadBalancer.id
}

output "Backend_Address_Pool_ID" {
  value = azurerm_lb_backend_address_pool.BAP.id
}

output "NAT_RDP_ID" {
  value = azurerm_lb_nat_rule.RDP.id
}