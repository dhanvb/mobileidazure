output "resource_group_location" {
  value = azurerm_resource_group.mobsdk.location
}

output "resource_group_name" {
  value = azurerm_resource_group.mobsdk.name
}

output "analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.insights.id
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}

output "subnet_id" {
  value = azurerm_subnet.subnet.id
}

output "subnet_scope" {
  value = azurerm_subnet.subnet.id
}

output "resource_group_id" {
  value = azurerm_resource_group.mobsdk.id
}