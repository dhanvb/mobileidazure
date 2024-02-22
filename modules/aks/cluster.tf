# Window's VM admin password
resource "random_password" "admin_password" {
  length           = 20
  special          = true
  override_special = "!#?"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                              = local.is_multi_environment ? "aks-${var.client}-mobsdk-${var.environments[0]}-${var.region}-001" : "aks-${var.client}-mobsdk-dev-${var.region}-001"
  resource_group_name               = var.resource_group_name
  location                          = var.region
  public_network_access_enabled     = true
  dns_prefix                        = var.dns_prefix
  automatic_channel_upgrade         = "rapid"
  role_based_access_control_enabled = true
  sku_tier                          = "Free"
  azure_policy_enabled              = true
  private_cluster_enabled           = false
  local_account_disabled            = false
  oidc_issuer_enabled               = true
  workload_identity_enabled         = true

  tags = {
    environment = join("; ", var.environments)
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  default_node_pool {
    name           = "linuxpool"
    node_count     = var.linux_node_count
    vm_size        = var.linux_vm_size
    max_pods       = 100
    vnet_subnet_id = var.subnet_id
  }

  identity {

    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "userAssignedNATGateway"
    dns_service_ip    = "10.23.32.10"
    service_cidr      = "10.23.32.0/24"
    nat_gateway_profile {
      idle_timeout_in_minutes = 4
    }
  }

  oms_agent {
    log_analytics_workspace_id = var.analytics_workspace_id
  }

  linux_profile {
    admin_username = "vbadmin"
    ssh_key {
      key_data = var.admin_ssh_key_data
    }
  }

  lifecycle {
    ignore_changes = [
      network_profile[0].nat_gateway_profile
    ]
  }

  windows_profile {
    admin_username = "vbadmin"
    admin_password = random_password.admin_password.result
  }
}

resource "azurerm_role_assignment" "subnet" {
  scope                = var.subnet_scope
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
  role_definition_name = "Network Contributor"
}

resource "azurerm_role_assignment" "aks" {
  scope                = data.azurerm_subscription.current.id
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
  role_definition_name = "Owner"
}

resource "azurerm_kubernetes_cluster_node_pool" "sysagentpool" {
  name                  = "sysagentpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.linux_vm_size
  node_count            = var.linux_node_count
  orchestrator_version  = "1.22.4" // or appropriate version
  os_type               = "Linux"
  enable_auto_scaling  = false // since you mentioned manual scaling
  max_pods              = 100
  enable_node_public_ip = false // if you don't want public IPs for nodes
  mode                  = "System"
  tags = {
    "nodepool-type" = "sysagentpool"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "usragentpool" {
  name                  = "usragentpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.windows_vm_size
  node_count            = var.windows_node_count
  orchestrator_version  = "1.22.4" // or appropriate version
  os_type               = "Windows"
  enable_auto_scaling  = false // since you mentioned manual scaling
  enable_node_public_ip = false // if you don't want public IPs for nodes
  mode                  = "User"
  tags = {
    "nodepool-type" = "usragentpool"
  }
}