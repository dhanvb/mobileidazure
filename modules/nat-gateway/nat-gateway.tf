resource "azurerm_public_ip_prefix" "nat_prefix" {
  name                = local.is_multi_environment ? "nat-prefix" : "nat-prefix-${var.environments[0]}"
  resource_group_name = var.resource_group_name
  location            = var.region
  ip_version          = "IPv4"
  prefix_length       = 31
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
}

resource "azurerm_nat_gateway" "gw_aks" {
  name                    = local.is_multi_environment ? "gw-aks" : "gw-aks-${var.environments[0]}"
  resource_group_name     = var.resource_group_name
  location                = var.region
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
}

resource "azurerm_nat_gateway_public_ip_prefix_association" "nat_ips" {
  nat_gateway_id      = azurerm_nat_gateway.gw_aks.id
  public_ip_prefix_id = azurerm_public_ip_prefix.nat_prefix.id
  depends_on = [
    azurerm_nat_gateway.gw_aks,
    azurerm_public_ip_prefix.nat_prefix
  ]
}

resource "azurerm_subnet_nat_gateway_association" "sn_cluster_nat_gw" {
  subnet_id      = var.subnet_id
  nat_gateway_id = azurerm_nat_gateway.gw_aks.id
  depends_on     = [azurerm_nat_gateway.gw_aks]
}