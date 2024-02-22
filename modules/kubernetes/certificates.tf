resource "kubectl_manifest" "certificates" {
  for_each = toset(var.environments)
  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      namespace = var.cert_manager_namespace
      name      = "certificates-for-${each.value}"
    }
    spec = {
      secretName = "app-secret-${each.value}"
      dnsNames = each.value == var.keycloak_env ? [
        "${var.backoffice_dns_name}.${each.value}.${var.dns}",
        "${var.gateway_dns_name}.${each.value}.${var.dns}",
        "${var.keycloak_dns_name}.${var.keycloak_env}.${var.dns}",
        ] : [
        "${var.backoffice_dns_name}.${each.value}.${var.dns}",
        "${var.gateway_dns_name}.${each.value}.${var.dns}"
      ]
      privateKey = {
        algorithm = "ECDSA"
        size      = 256
      }
      issuerRef = {
        kind = "ClusterIssuer"
        name = var.cluster_issuer_name
      }
    }
  })
  depends_on = [
    kubernetes_namespace.namespace,
    kubernetes_secret.registry
  ]
}
