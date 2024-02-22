resource "random_id" "log_analytics_workspace_name_suffix" {
  byte_length = 8
}

resource "azurerm_log_analytics_workspace" "insights" {
  location            = azurerm_resource_group.mobsdk.location
  name                = local.is_multi_environment ? "logs-${random_id.log_analytics_workspace_name_suffix.dec}" : "logs-${random_id.log_analytics_workspace_name_suffix.dec}-${var.environments[0]}"
  resource_group_name = azurerm_resource_group.mobsdk.name
  retention_in_days   = 30
}