resource "azurerm_resource_group" "mobsdk" {
  name     = local.is_multi_environment ? "rg-${var.client}-mobsdk-${var.environments[0]}-${var.region}-001" : "rg-${var.client}-mobsdk-dev-${var.region}-001"
  location = var.region

  tags = {
    environment = local.is_multi_environment ? join(", ", var.environments) : "${var.environments[0]}"
    client      = var.client
  }
}