module "base" {
  source               = "../../modules/base"
  client               = local.config.client
  region               = local.region
  environments         = var.environments
  cluster_principal_id = module.aks.cluster_principal_id
}

module "nat-gateway" {
  source              = "../../modules/nat-gateway"
  environments        = var.environments
  resource_group_name = module.base.resource_group_name
  region              = module.base.resource_group_location
  subnet_id           = module.base.subnet_id
}

module "nginx_ingress_controller" {
  source                    = "../../modules/nginx-ingress"
  aks_host                  = module.aks.host
  aks_client_certificate    = module.aks.client_certificate
  aks_client_key            = module.aks.client_key
  aks_cluster_ca_certificate = module.aks.cluster_ca_certificate
  aks_subnet_id             = module.base.subnet_id
  aks_node_resource_group_id = module.base.resource_group_id
}

module "aks" {
  source                 = "../../modules/aks"
  linux_node_count       = local.config.k8s_linux_node_count
  linux_vm_size          = local.config.k8s_linux_vm_size
  resource_group_name    = module.base.resource_group_name
  region                 = module.base.resource_group_location
  client                 = local.config.client
  windows_node_count     = local.config.k8s_windows_node_count
  windows_vm_size        = local.config.k8s_windows_vm_size
  dns_prefix             = local.config.k8s_dns_prefix
  analytics_workspace_id = module.base.analytics_workspace_id
  admin_ssh_key_data     = var.admin_ssh_key_data
  environments           = var.environments
  subnet_id              = module.base.subnet_id
  subnet_scope           = module.base.subnet_scope
}

module "db_server" {
  source                = "../../modules/db-server"
  backup_retention_days = local.config.db_backup_retention_days
  postgres_version      = local.config.postgres_version
  region                = module.base.resource_group_location
  resource_group_name   = module.base.resource_group_name
  sku                   = local.config.db_sku
  storage_size          = local.config.db_storage_size
  high_availability     = local.config.high_availability
  environments          = var.environments
  subnet_id             = module.base.subnet_id
}

module "db" {
  source              = "../../modules/db"
  db_server           = module.db_server.name
  resource_group_name = module.base.resource_group_name
  environments        = var.environments
}

