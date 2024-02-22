output "nat_gateway_aks" {
  value = azurerm_public_ip_prefix.nat_prefix.ip_prefix
}