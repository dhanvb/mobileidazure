# Liveness cluster IP
resource "kubernetes_service" "liveness_clusterIP" {
  metadata {
    name      = "liveness"
    namespace = var.liveness_env
  }

  spec {
    selector = {
      app = "liveness"
    }

    type = "ClusterIP"

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

# Liveness pods
resource "kubernetes_deployment" "liveness" {
  metadata {
    name      = "liveness"
    namespace = var.liveness_env
    labels = {
      "app" = "liveness"
    }
  }

  spec {
    replicas = var.liveness_replicas

    selector {
      match_labels = {
        "app" = "liveness"
      }
    }

    template {
      metadata {
        labels = {
          "app" = "liveness"
        }
      }

      spec {
        image_pull_secrets {
          name = kubernetes_secret.registry[var.liveness_env].metadata[0].name
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
          name              = "idrnd-server"
          image             = "${local.registry[var.liveness_env].container_registry_name}/${local.registry[var.liveness_env].prefix}idfaceserver:${var.liveness_version}"
          image_pull_policy = "Always"

          security_context {
            capabilities {
              drop = [
                "ALL"
              ]
            }
          }

          port {
            name           = "http"
            container_port = 8080
          }

          resources {
            limits = {
              "cpu"    = "250m"
              "memory" = "4000Mi"
            }
            requests = {
              "cpu"    = "250m"
              "memory" = "4000Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/api_version"
              port = "http"
            }

            initial_delay_seconds = 60
            period_seconds        = 30
            timeout_seconds       = 5
            failure_threshold     = 5
          }

          readiness_probe {
            http_get {
              path = "/api_version"
              port = "http"
            }

            initial_delay_seconds = 60
            period_seconds        = 30
            timeout_seconds       = 1
            failure_threshold     = 5
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