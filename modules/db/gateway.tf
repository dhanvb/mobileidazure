
resource "azurerm_postgresql_database" "gateway" {
  for_each            = toset(var.environments)
  name                = "gateway-${each.value}"
  resource_group_name = var.resource_group_name
  server_name         = var.db_server
  charset             = "UTF8"
  collation           = "English_United States.1252"
}
