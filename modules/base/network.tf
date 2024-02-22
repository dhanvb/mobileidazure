# VNET
resource "azurerm_virtual_network" "vnet" {
  name                = local.is_multi_environment ? "vnet-sharedpaas-${var.client}-mobsdk-${var.environments[0]}-${var.region}-001" : "vnet-sharedpaas-dev-${var.region}-001"
  location            = azurerm_resource_group.mobsdk.location
  resource_group_name = azurerm_resource_group.mobsdk.name
  address_space       = ["172.25.192.0/20"]
  }

 resource "azurerm_subnet" "subnet" {
  name                 = "snet-mtvb-mobsdk-dev-eastus2-001"
  resource_group_name  = azurerm_resource_group.mobsdk.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["172.25.193.0/25"]
  }

resource "azurerm_route_table" "udr" {
  name                = "udr-network-rodev-eastus2-001"
  resource_group_name = azurerm_resource_group.mobsdk.name
  location            = azurerm_resource_group.mobsdk.location

route {
    name                   = "DefaultRoute"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "172.17.65.36"
  }
}

resource "azurerm_subnet_route_table_association" "subnet_association" {
  subnet_id      = azurerm_subnet.subnet.id
  route_table_id = azurerm_route_table.udr.id
}