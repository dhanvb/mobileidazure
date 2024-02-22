output "gateway_db" {
  value = { for env, db in azurerm_postgresql_database.gateway : env => db.name }
}