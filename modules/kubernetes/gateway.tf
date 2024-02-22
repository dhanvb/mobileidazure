locals {
  dbs = var.gateway_db

  depends_on = [
    kubernetes_namespace.namespace,
    kubernetes_secret.registry
  ]

  data_flow_injection_credentials = jsondecode(var.subjects_data_flow_injection_credentials)

}

# Gateway roles
resource "kubernetes_role" "gateway_role" {
  for_each = toset(var.environments)
  metadata {
    name      = "job-reader"
    namespace = each.value
  }

  rule {
    api_groups = ["batch"]
    resources  = ["jobs"]
    verbs      = ["get", "list", "watch"]
  }

  depends_on = [
    kubernetes_namespace.namespace,
    kubernetes_secret.registry
  ]
}

# Gateway role binding
resource "kubernetes_role_binding" "gateway_role_binding" {
  for_each = toset(var.environments)
  metadata {
    name      = "default-job-reader"
    namespace = each.value
  }

  role_ref {
    name      = kubernetes_role.gateway_role[each.value].metadata[0].name
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
  }

  subject {
    name      = "default"
    kind      = "ServiceAccount"
    namespace = each.value
  }
  depends_on = [
    kubernetes_namespace.namespace,
    kubernetes_secret.registry
  ]
}

# gatewaydev's secrets
resource "kubernetes_secret" "gateway" {
  for_each = toset(var.environments)
  metadata {
    name      = "gateway-${each.value}-secrets"
    namespace = each.value
  }

  data = {
    Persistence__ConnectionString                                    = "Host=postgres.postgres-proxy;Username=${var.gateway_db_user};Password=${var.gateway_db_password};Database=${local.dbs[each.value]};SslMode=Require;Trust Server Certificate=true"
    Providers__Liveness__LivenessCheckApiKey                         = var.liveness_api_key
    AzureStorage__ConnectionString                                   = "DefaultEndpointsProtocol=https;AccountName=${var.azure_storage_account_name};AccountKey=${var.azure_storage_account_key};EndpointSuffix=core.windows.net"
    Providers__Subjects__Security__OAuth2__Credentials__ClientSecret = "${local.data_flow_injection_credentials[each.value].client_secret}"
    Providers__Subjects__Security__OAuth2__Credentials__ClientId     = "${local.data_flow_injection_credentials[each.value].client_id}"
  }
  depends_on = [
    kubernetes_namespace.namespace,
    kubernetes_secret.registry
  ]
}

# gatewaydev's migrations secrets
resource "kubernetes_secret" "gateway_migrations" {
  for_each = toset(var.environments)
  metadata {
    name      = "gateway-${each.value}-migrations-secrets"
    namespace = each.value
  }

  data = {
    Persistence__ConnectionString            = "Host=postgres.postgres-proxy;Username=${var.gateway_db_user};Password=${var.gateway_db_password};Database=${local.dbs[each.value]};SSLMode=Require;Trust Server Certificate=true"
    Providers__Liveness__LivenessCheckApiKey = var.liveness_api_key
    AzureStorage__ConnectionString           = "DefaultEndpointsProtocol=https;AccountName=${var.azure_storage_account_name};AccountKey=${var.azure_storage_account_key};EndpointSuffix=core.windows.net"
  }
  depends_on = [
    kubernetes_namespace.namespace,
    kubernetes_secret.registry
  ]
}

# gatewaydev's environment variables
resource "kubernetes_config_map" "gateway" {
  for_each = toset(var.environments)
  metadata {
    name      = "gateway-${each.value}-env-vars"
    namespace = each.value
  }

  data = {
    AllowedOrigins                                      = "https://${var.backoffice_dns_name}.${each.value}.${var.dns}"
    Persistence__AutoApplySchemaEvolutions              = "false"
    Providers__Biometric__ProcessUri                    = "http://localhost/VisiontecFR5/Process"
    Providers__Biometric__MatchUri                      = "http://localhost/VisiontecFR5/Match"
    Providers__Biometric__Security__Enabled             = "false"
    Providers__Liveness__LivenessCheckUri               = "http://${kubernetes_service.liveness_clusterIP.spec[0].cluster_ip}/check_liveness"
    AzureStorage__ResourcesBaseUri                      = "https://${var.azure_storage_account_name}.blob.core.windows.net/"
    AzureStorage__RootDirectory                         = "Backoffice/${var.client}/${each.value}"
    Authentication__Authority                           = "https://${var.keycloak_dns_name}.${var.keycloak_env}.${var.dns}/realms/master"
    Biometric__PhotoGatheringEnabled                    = "false"
    Providers__Subjects__SubjectsUri                    = "https://localhost:9000/FlowDataInjection/1.0.0/Subjects"
    Clients__SubjectMatcher__BaseAddress                = "${var.match_service_address}/api/v1.0/"
    Clients__SubjectMatcher__Security__Enabled          = "false"
    Providers__Subjects__Security__OAuth2__BaseUri      = "${local.data_flow_injection_credentials[each.value].url}"
    Clients__SubjectMatcher__Security__OAuth2__Provider = "http://localhost/token"
    Logging__RetainedFileCountLimit                     = "7"
    ASPNETCORE_URLS                                     = "http://+:5001"
  }
  depends_on = [
    kubernetes_namespace.namespace,
    kubernetes_secret.registry
  ]
}

# Backoffice ingress to receive requests from outside
resource "kubernetes_ingress_v1" "gateway_ingress" {
  for_each = toset(var.environments)
  metadata {
    name      = "gateway-${each.value}"
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
      hosts       = ["${var.gateway_dns_name}.${each.value}.${var.dns}"]
      secret_name = "gateway"
    }
    rule {
      host = "${var.gateway_dns_name}.${each.value}.${var.dns}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "gateway-${each.value}"
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
resource "kubernetes_service" "gateway_clusterIP" {
  for_each = toset(var.environments)
  metadata {
    name      = "gateway-${each.value}"
    namespace = each.value
  }

  spec {
    selector = {
      app = "gateway-${each.value}"
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

# gatewaydev migrations job
resource "kubernetes_job" "gateway_migrations" {
  for_each = toset(var.environments)
  metadata {
    name      = "gateway-${each.value}-migrations"
    namespace = each.value
  }

  spec {
    template {
      metadata {
        name = "gateway-${each.value}-migrations"
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
          name              = "gateway-${each.value}-migrations"
          image             = "${local.registry[each.value].container_registry_name}/${local.registry[each.value].prefix}mobileapigateway:${var.gateway_version}"
          image_pull_policy = "Always"
          args              = ["--migrate"]

          security_context {
            capabilities {
              drop = [
                "ALL"
              ]
            }
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.gateway[each.value].metadata[0].name
            }
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.gateway_migrations[each.value].metadata[0].name
            }
          }
        }

        restart_policy = "Never"
      }
    }

    backoff_limit = 1
  }
  wait_for_completion = true
  timeouts {
    create = "10m"
    update = "10m"
  }
  depends_on = [
    kubernetes_namespace.namespace,
    kubernetes_secret.registry
  ]
}

# gatewaydev pods
resource "kubernetes_deployment" "gateway_deployment" {
  for_each = toset(var.environments)
  metadata {
    name      = "gateway-${each.value}"
    namespace = each.value
    labels = {
      "app" = "gateway-${each.value}"
    }
  }

  spec {
    replicas = var.gateway_replicas

    selector {
      match_labels = {
        "app" = "gateway-${each.value}"
      }
    }

    template {
      metadata {
        labels = {
          "app" = "gateway-${each.value}"
        }
      }

      spec {
        init_container {
          name  = "gateway-${each.value}-init"
          image = "groundnuty/k8s-wait-for:v1.7"
          args = [
            "job",
            kubernetes_job.gateway_migrations[each.value].metadata[0].name
          ]
        }

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
          name              = "gateway-${each.value}"
          image             = "${local.registry[each.value].container_registry_name}/${local.registry[each.value].prefix}mobileapigateway:${var.gateway_version}"
          image_pull_policy = "Always"

          security_context {
            capabilities {
              drop = [
                "ALL"
              ]
            }
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.gateway[each.value].metadata[0].name
            }
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.gateway[each.value].metadata[0].name
            }
          }

          port {
            name           = "http"
            container_port = 5001
          }

          resources {
            limits = {
              "cpu"               = "250m"
              "ephemeral-storage" = "250Mi"
              "memory"            = "750Mi"
            }
            requests = {
              "cpu"               = "250m"
              "ephemeral-storage" = "250Mi"
              "memory"            = "750Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = "http"
            }

            initial_delay_seconds = 60
            period_seconds        = 15
            timeout_seconds       = 5
            failure_threshold     = 5
          }

          readiness_probe {
            http_get {
              path = "/"
              port = "http"
            }

            initial_delay_seconds = 15
            period_seconds        = 15
            timeout_seconds       = 2
            failure_threshold     = 3
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_namespace.namespace,
    kubernetes_secret.registry,
    kubernetes_role_binding.gateway_role_binding
  ]
}

