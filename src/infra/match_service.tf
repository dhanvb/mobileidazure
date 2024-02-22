resource "azurerm_container_group" "match_service" {
  name                = local.is_multi_environment ? "biometricmatchservice" : "biometricmatchservice-${var.environments[0]}"
  location            = local.region
  resource_group_name = module.base.resource_group_name
  ip_address_type     = "Public"
  dns_name_label      = local.is_multi_environment ? "biometricmatchservice" : "biometricmatchservice-${var.environments[0]}"
  os_type             = "Windows"

  image_registry_credential {
    server   = var.container_registry_name
    username = var.container_registry_username
    password = var.container_registry_password
  }

  timeouts {
    create = "90m"
    update = "90m"
    delete = "90m"
  }

  container {
    name   = "biometricmatchservice"
    image  = "${var.container_registry_name}/biometricmatchservice:${local.config.match_service_version}"
    cpu    = "2"
    memory = "2"

    ports {
      port     = 5000
      protocol = "TCP"
    }
  }
}
