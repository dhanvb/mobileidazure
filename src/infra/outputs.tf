output "resource_group" {
  value = module.base.resource_group_name
}

output "resource_group_name" {
  value = module.base.resource_group_name
}

output "aks_host" {
  value     = module.aks.host
  sensitive = true
}

output "aks_username" {
  value     = module.aks.username
  sensitive = true
}

output "aks_password" {
  value     = module.aks.password
  sensitive = true
}

output "aks_client_certificate" {
  value     = module.aks.client_certificate
  sensitive = true
}

output "aks_client_key" {
  value     = module.aks.client_key
  sensitive = true
}

output "aks_cluster_ca_certificate" {
  value     = module.aks.cluster_ca_certificate
  sensitive = true
}

output "match_service_address" {
  value = "http://${azurerm_container_group.match_service.fqdn}:5000"
}

output "cluster_oidc_issuer_url" {
  value     = module.aks.cluster_oidc_issuer_url
  sensitive = true
}

output "resource_group_location" {
  value = module.base.resource_group_location
}

# database export
output "database_address" {
  value = module.db_server.address
}

output "db_ip_address" {
  value = module.db_server.db_ip_address
}

output "gateway_db" {
  value = module.db.gateway_db
}

output "gateway_db_user" {
  value = "${module.db_server.admin}@${module.db_server.name}"
}

output "gateway_db_password" {
  value     = module.db_server.admin_password
  sensitive = true
}

output "subnet_scope" {
  value = module.base.subnet_scope
}
