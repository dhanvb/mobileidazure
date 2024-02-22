locals {
  cert_manager_namespace            = "cert-manager"
  cert_manager_service_account_name = "cert-manager"
  cluster_issuer_name               = "cert-manager-ingress-letsencrypt"
  solvers = flatten([for env in var.environments : {
    selector = {
      dnsZones = ["${env}.${var.dns}"]
    }
    dns01 = {
      azureDNS = {
        subscriptionID    = data.azurerm_client_config.current.subscription_id
        resourceGroupName = var.resource_group_name
        hostedZoneName    = "${env}.${var.dns}"
        managedIdentity = {
          clientID = azurerm_user_assigned_identity.cert_manager.client_id
        }
      }
    }
  }])
}

resource "azurerm_user_assigned_identity" "cert_manager" {
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  name                = "cert-manager"
}

resource "azurerm_federated_identity_credential" "cert_manager" {
  resource_group_name = var.resource_group_name
  name                = "cert-manager"
  parent_id           = azurerm_user_assigned_identity.cert_manager.id
  issuer              = var.cluster_oidc_issuer_url
  subject             = "system:serviceaccount:${local.cert_manager_namespace}:${local.cert_manager_service_account_name}"
  audience            = ["api://AzureADTokenExchange"]
}

resource "azurerm_role_assignment" "cert_manager" {
  for_each             = tomap(var.dns_zone_ingress_ids)
  scope                = each.value
  principal_id         = azurerm_user_assigned_identity.cert_manager.principal_id
  role_definition_name = "DNS Zone Contributor"
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = local.cert_manager_namespace
  }
}

resource "helm_release" "cert_manager" {
  namespace  = local.cert_manager_namespace
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.11.1"
  values = [yamlencode({
    installCRDs = true
    podLabels = {
      "azure.workload.identity/use" = "true"
    }
    serviceAccount = {
      name = local.cert_manager_service_account_name
    }
  })]
}

resource "kubectl_manifest" "cert_manager_ingress" {
  depends_on = [
    helm_release.cert_manager
  ]
  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      namespace = local.cert_manager_namespace
      name      = local.cluster_issuer_name
    }
    spec = {
      acme = {
        name   = "letsencrypt"
        server = var.letsencrypt_server
        email  = var.letsencrypt_email
        privateKeySecretRef = {
          name = "mobileid"
        }
        solvers = local.solvers
      }
    }
  })
}
