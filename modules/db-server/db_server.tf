# DB server's admin password
resource "random_password" "admin_password" {
  length           = 20
  special          = true
  override_special = "!#?"
}

# Database server
resource "azurerm_postgresql_server" "postgres" {
  name                              = local.is_multi_environment ? "mobileid-msc-db" : "mobileid-msc-db-${var.environments[0]}"
  location                          = var.region
  resource_group_name               = var.resource_group_name
  sku_name                          = var.sku
  storage_mb                        = var.storage_size * 1024
  backup_retention_days             = var.backup_retention_days
  geo_redundant_backup_enabled      = var.high_availability
  auto_grow_enabled                 = true
  administrator_login               = "vbadmin"
  administrator_login_password      = random_password.admin_password.result
  version                           = var.postgres_version
  ssl_enforcement_enabled           = true
  infrastructure_encryption_enabled = false
  ssl_minimal_tls_version_enforced  = "TLS1_2"
  public_network_access_enabled     = false

  threat_detection_policy {
    enabled = true
  }
}

resource "azurerm_private_endpoint" "postgres_endpoint" {
  name                = "postgres-endpoint"
  location            = var.region
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "postgres-privateserviceconnection"
    private_connection_resource_id = azurerm_postgresql_server.postgres.id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }
}
