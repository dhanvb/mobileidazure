# Backoffice environment variables
resource "kubernetes_config_map" "backoffice" {
  for_each = toset(var.environments)
  metadata {
    name      = "backoffice-${each.value}-env-vars"
    namespace = each.value
  }

  data = {
    IDENTITY_SERVER_URI = "https://${var.keycloak_dns_name}.${var.keycloak_env}.${var.dns}"
    API_URI             = "https://${var.gateway_dns_name}.${each.value}.${var.dns}"
  }
  depends_on = [
    kubernetes_namespace.namespace,
    kubernetes_secret.registry
  ]
}

# Backoffice ingress to receive requests from outside
resource "kubernetes_ingress_v1" "backoffice_ingress" {
  for_each = toset(var.environments)
  metadata {
    name      = "backoffice-${each.value}"
    namespace = each.value
    labels = {
      "app" = "${each.value}"
    }
    annotations = {
      "cert-manager.io/cluster-issuer" : var.cluster_issuer_name
      "kubernetes.io/ingress.class" : "traefik"
      "acme.cert-manager.io/http01-edit-in-place" : "true"
    }
  }

  spec {
    tls {
      hosts       = ["${var.backoffice_dns_name}.${each.value}.${var.dns}"]
      secret_name = "backoffice"
    }
    rule {
      host = "${var.backoffice_dns_name}.${each.value}.${var.dns}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "backoffice-${each.value}"
              port {
                name = "http"
              }
            }
          }
        }
      }
    }
  }
  depends_on = [
    kubernetes_namespace.namespace,
    kubernetes_secret.registry
  ]
}

# Cluster IP
resource "kubernetes_service" "backoffice_clusterIP" {
  for_each = toset(var.environments)
  metadata {
    name      = "backoffice-${each.value}"
    namespace = each.value
  }

  spec {
    selector = {
      app = "backoffice-${each.value}"
    }

    type = "LoadBalancer"

    port {
      name        = "http"
      port        = 80
      protocol    = "TCP"
      target_port = "http"
    }
  }
  depends_on = [
    kubernetes_namespace.namespace,
    kubernetes_secret.registry
  ]
}

# pods
resource "kubernetes_deployment" "backoffice" {
  for_each = toset(var.environments)
  metadata {
    name      = "backoffice-${each.value}"
    namespace = each.value
    labels = {
      "app" = "backoffice-${each.value}"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app" = "backoffice-${each.value}"
      }
    }

    template {
      metadata {
        labels = {
          "app" = "backoffice-${each.value}"
        }
      }

      spec {
        image_pull_secrets {
          name = kubernetes_secret.registry[each.value].metadata[0].name
        }

        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "kubernetes.io/os"
                  operator = "In"
                  values = [
                    "linux"
                  ]
                }
              }
            }
          }
        }

        container {
          name              = "backoffice-${each.value}"
          image             = "${local.registry[each.value].container_registry_name}/${local.registry[each.value].prefix}backoffice:${var.backoffice_version}"
          image_pull_policy = "Always"

          env_from {
            config_map_ref {
              name = kubernetes_config_map.backoffice[each.value].metadata[0].name
            }
          }

          # NGINX REQUIRES ROOT USER. NEED TO FIX IT IN NEXT VERSION.
          # security_context {
          #   capabilities {
          #     drop = [
          #       "ALL"
          #     ]
          #   }
          # }

          port {
            name           = "http"
            container_port = 3000
          }

          resources {
            limits = {
              "cpu"    = "15m"
              "memory" = "25Mi"
            }
            requests = {
              "cpu"    = "15m"
              "memory" = "25Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = "http"
            }

            initial_delay_seconds = 30
            period_seconds        = 15
            timeout_seconds       = 5
            failure_threshold     = 5
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = "http"
            }

            initial_delay_seconds = 15
            period_seconds        = 15
            timeout_seconds       = 1
            failure_threshold     = 3
          }
        }
      }
    }
  }
  depends_on = [
    kubernetes_namespace.namespace,
    kubernetes_secret.registry
  ]
}