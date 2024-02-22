output "name" {
  value = azurerm_postgresql_server.postgres.name
}

output "address" {
  value = azurerm_postgresql_server.postgres.fqdn
}

output "db_ip_address" {
  value = azurerm_private_endpoint.postgres_endpoint.private_service_connection.0.private_ip_address
}

output "admin" {
  value = azurerm_postgresql_server.postgres.administrator_login
}

output "admin_password" {
  value = azurerm_postgresql_server.postgres.administrator_login_password
}
