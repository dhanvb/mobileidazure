# Postgres proxy namespace
resource "kubernetes_namespace" "postgres_proxy" {
  metadata {
    name = "postgres-proxy"
  }
}

# Postgres cluster ip endpoints
resource "kubernetes_endpoints" "postgres_endpoints" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.postgres_proxy.id
  }

  subset {
    address {
      ip = var.db_ip_address
    }

    port {
      port = 5432
    }
  }
}

# Cluster IP
resource "kubernetes_service" "postgres_clusterIP" {
  metadata {
    name      = kubernetes_endpoints.postgres_endpoints.metadata[0].name
    namespace = kubernetes_namespace.postgres_proxy.id
  }

  spec {
    type = "ClusterIP"

    port {
      port        = 5432
      protocol    = "TCP"
      target_port = 5432
    }
  }
}

# Cluster IP for port forwarding
resource "kubernetes_service" "postgres_proxy_clusterIP" {
  metadata {
    name      = "postgres-proxy"
    namespace = kubernetes_namespace.postgres_proxy.id
  }

  spec {
    type = "ClusterIP"

    selector = {
      "app" = "postgres-proxy"
    }

    port {
      name        = "psql"
      port        = 5432
      protocol    = "TCP"
      target_port = "psql"
    }
  }
}

# Postgres proxy pods
# TODO: Find a way to have health probes and remove skip checks of CKV_K8S_8 and CKV_K8S_9
resource "kubernetes_deployment" "postgres_proxy" {
  metadata {
    name      = "postgres-proxy"
    namespace = kubernetes_namespace.postgres_proxy.id
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app" = "postgres-proxy"
      }
    }

    template {
      metadata {
        labels = {
          "app" = "postgres-proxy"
        }
      }

      spec {
        container {
          name              = "postgres-proxy"
          image             = "alpine/socat:1.7.4.4-r0"
          image_pull_policy = "Always"
          args = [
            "tcp-listen:5432,fork,reuseaddr",
            "tcp-connect:postgres:5432"
          ]

          security_context {
            capabilities {
              drop = [
                "ALL"
              ]
            }
          }

          port {
            name           = "psql"
            container_port = 5432
          }

          resources {
            limits = {
              "cpu"    = "0.1"
              "memory" = "40Mi"
            }
            requests = {
              "cpu"    = "0.1"
              "memory" = "40Mi"
            }
          }
        }
      }
    }
  }
}
