
module "certificate" {
  source                     = "../../modules/certificate"
  resource_group_name        = var.resource_group
  dns_zone_ingress_ids       = module.dns.dns_zone_ingress_ids
  dns                        = local.config.dns
  environments               = var.environments
  resource_group_location    = var.resource_group_location
  cluster_oidc_issuer_url    = var.cluster_oidc_issuer_url
  aks_host                   = var.aks_host
  aks_client_certificate     = var.aks_client_certificate
  aks_client_key             = var.aks_client_key
  aks_cluster_ca_certificate = var.aks_cluster_ca_certificate
}

module "ingress" {
  source                     = "../../modules/ingress"
  aks_host                   = var.aks_host
  aks_client_certificate     = var.aks_client_certificate
  aks_client_key             = var.aks_client_key
  aks_cluster_ca_certificate = var.aks_cluster_ca_certificate
}

module "k8s" {
  source                                   = "../../modules/kubernetes"
  client                                   = local.config.client
  environments                             = var.environments
  liveness_replicas                        = local.config.liveness_replicas
  liveness_version                         = local.config.liveness_version
  db_address                               = var.database_address
  db_ip_address                            = var.db_ip_address
  keycloak_version                         = local.config.keycloak_version
  gateway_db                               = var.gateway_db
  gateway_db_user                          = var.gateway_db_user
  gateway_db_password                      = var.gateway_db_password
  gateway_version                          = local.config.gateway_version
  gateway_replicas                         = local.config.gateway_replicas
  backoffice_version                       = local.config.backoffice_version
  azure_storage_account_key                = var.azure_storage_account_key
  azure_storage_account_name               = var.azure_storage_account_name
  container_registry_name                  = var.container_registry_name
  container_registry_username              = var.container_registry_username
  container_registry_password              = var.container_registry_password
  dev_container_registry_name              = var.dev_container_registry_name
  dev_container_registry_username          = var.dev_container_registry_username
  dev_container_registry_password          = var.dev_container_registry_password
  liveness_api_key                         = var.liveness_api_key
  match_service_address                    = var.match_service_address
  resource_group                           = var.resource_group
  resource_group_location                  = local.region
  cluster_oidc_issuer_url                  = var.cluster_oidc_issuer_url
  dns_zone_ingress_ids                     = module.dns.dns_zone_ingress_ids
  dns                                      = local.config.dns
  backoffice_dns_name                      = local.config.backoffice_dns_name
  gateway_dns_name                         = local.config.gateway_dns_name
  keycloak_dns_name                        = local.config.keycloak_dns_name
  keycloak_env                             = var.environments[(length(var.environments) - 1)]
  liveness_env                             = var.environments[(length(var.environments) - 1)]
  cluster_issuer_name                      = module.certificate.cluster_issuer_name
  cert_manager_namespace                   = module.certificate.cert_manager_namespace
  subjects_data_flow_injection_credentials = var.subjects_data_flow_injection_credentials
}


module "dns" {
  source                     = "../../modules/dns"
  resource_group             = var.resource_group
  dns                        = local.config.dns
  environments               = var.environments
  aks_host                   = var.aks_host
  aks_client_certificate     = var.aks_client_certificate
  aks_client_key             = var.aks_client_key
  aks_cluster_ca_certificate = var.aks_cluster_ca_certificate
}

