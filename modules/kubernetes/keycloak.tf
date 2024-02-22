# Keycloak's admin password
resource "random_password" "keycloak_admin" {
  length           = 20
  special          = true
  override_special = "!#?"
  depends_on = [
    kubernetes_namespace.namespace,
    kubernetes_secret.registry
  ]
}

resource "kubernetes_ingress_v1" "keycloak_ingress" {
  metadata {
    name      = "keycloak-${var.keycloak_env}"
    namespace = var.keycloak_env
    labels = {
      "app" = "keycloak"
    }
    annotations = {
      "cert-manager.io/cluster-issuer" : var.cluster_issuer_name
      "kubernetes.io/ingress.class" : "traefik"
      "acme.cert-manager.io/http01-edit-in-place" : "true"
    }
  }

  spec {
    tls {
      hosts       = ["${var.keycloak_dns_name}.${var.keycloak_env}.${var.dns}"]
      secret_name = "keycloak"
    }
    rule {
      host = "${var.keycloak_dns_name}.${var.keycloak_env}.${var.dns}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "keycloak"
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

# Keycloak's admin user secret variables
resource "kubernetes_secret" "keycloak_admin_user" {
  metadata {
    name      = "keycloak-user"
    namespace = var.keycloak_env
  }

  data = {
    KEYCLOAK_ADMIN          = "admin"
    KEYCLOAK_ADMIN_PASSWORD = random_password.keycloak_admin.result
  }
  depends_on = [
    kubernetes_namespace.namespace,
    kubernetes_secret.registry
  ]
}

# Keycloak cluster IP
resource "kubernetes_service" "keycloak_clusterIP" {
  metadata {
    name      = "keycloak"
    namespace = var.keycloak_env
  }

  spec {
    selector = {
      app = "keycloak"
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

# Keycloak pods
resource "kubernetes_deployment" "keycloak" {
  metadata {
    name      = "keycloak"
    namespace = var.keycloak_env
    labels = {
      "app" = "keycloak"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app" = "keycloak"
      }
    }

    template {
      metadata {
        labels = {
          "app" = "keycloak"
        }
      }

      spec {
        image_pull_secrets {
          name = kubernetes_secret.registry[var.keycloak_env].metadata[0].name
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
          name              = "keycloak"
          image             = "${local.registry[var.keycloak_env].container_registry_name}/${local.registry[var.keycloak_env].prefix}keycloak:${var.keycloak_version}"
          image_pull_policy = "Always"

          security_context {
            capabilities {
              drop = [
                "ALL"
              ]
            }
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.keycloak_admin_user.metadata[0].name
            }
          }

          port {
            name           = "http"
            container_port = 8080
          }

          resources {
            limits = {
              "cpu"    = "500m"
              "memory" = "1200Mi"
            }
            requests = {
              "cpu"    = "500m"
              "memory" = "1000Mi"
            }
          }

          startup_probe {
            http_get {
              path = "/realms/master"
              port = "http"
            }

            initial_delay_seconds = 0
            period_seconds        = 10
            timeout_seconds       = 1
            failure_threshold     = 30
          }

          liveness_probe {
            http_get {
              path = "/realms/master"
              port = "http"
            }

            initial_delay_seconds = 120
            period_seconds        = 15
            timeout_seconds       = 5
            failure_threshold     = 5
          }

          readiness_probe {
            http_get {
              path = "/realms/master"
              port = "http"
            }

            initial_delay_seconds = 60
            period_seconds        = 15
            timeout_seconds       = 1
            failure_threshold     = 10
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
