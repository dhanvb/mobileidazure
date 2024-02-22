resource "azurerm_private_dns_zone" "aks_private_dns" {
  name                = "aks-mtvb-mobsdk-dev-eastus2-001.privatelink.switzerlandnorth.azmk8s.io"
  resource_group_name = var.resource_group
}

resource "azurerm_private_dns_a_record" "aks_dns_a_record" {
  name             = "aks-mtvb-mobsdk-dev-eastus2-001"
  zone_name        = azurerm_private_dns_zone.aks_private_dns.name
  resource_group_name = var.resource_group
  ttl              = 300  # Adjust TTL as needed
  records          = ["xxx.xxx.xxx.xxx"]  # Replace with the actual IP address
}

data "azurerm_kubernetes_cluster" "cluster" {
  for_each = var.environments
  name     = azurerm_kubernetes_cluster.aks[0].name
  resource_group_name = var.resource_group
}

resource "azurerm_private_dns_a_record" "aks_dns_a_record" {
  for_each = var.environments
  
  name             = "aks-mtvb-mobsdk-dev-eastus2-001"
  zone_name        = azurerm_private_dns_zone.aks_private_dns.name
  resource_group_name = var.resource_group
  ttl              = 300  # Adjust TTL as needed
  records          = [data.azurerm_kubernetes_cluster.cluster[each.key].fqdn] 
}

resource "azuread_application" "external_dns" {
  for_each     = toset(var.environments)
  display_name = "${var.resource_group}-external-dns-${each.value}"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "time_rotating" "external_dns" {
  rotation_days = 7
}

resource "azuread_application_password" "external_dns" {
  for_each              = toset(var.environments)
  application_object_id = azuread_application.external_dns[each.value].object_id
  rotate_when_changed = {
    rotation = time_rotating.external_dns.id
  }
}

resource "azuread_service_principal" "external_dns" {
  for_each                     = toset(var.environments)
  application_id               = azuread_application.external_dns[each.value].application_id
  owners                       = [data.azuread_client_config.current.object_id]
  app_role_assignment_required = false
}

resource "azurerm_role_assignment" "external_dns" {
  for_each             = toset(var.environments)
  scope                = azurerm_dns_zone.ingress[each.value].id
  principal_id         = azuread_service_principal.external_dns[each.key].id
  role_definition_name = "DNS Zone Contributor"
}

resource "helm_release" "external_dns" {
  for_each   = toset(var.environments)
  namespace  = "kube-system"
  name       = "external-dns-${each.value}"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  version    = "6.18.0"
  values = [yamlencode({
    policy     = "sync"
    txtOwnerId = var.resource_group
    sources = [
      "ingress"
    ]
    domainFilters = ["${each.value}.${var.dns}"]
    provider      = "azure"
    azure = {
      tenantId        = data.azurerm_client_config.current.tenant_id
      subscriptionId  = data.azurerm_client_config.current.subscription_id
      resourceGroup   = azurerm_dns_zone.ingress[each.value].resource_group_name
      aadClientId     = azuread_service_principal.external_dns[each.value].application_id
      aadClientSecret = azuread_application_password.external_dns[each.value].value
    }
  })]
}