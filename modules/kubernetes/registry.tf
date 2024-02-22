locals {
  registry = {
    dev = {
      container_registry_name     = var.dev_container_registry_name
      container_registry_username = var.dev_container_registry_username
      container_registry_password = var.dev_container_registry_password
      prefix                      = "dev"
    }
    qa = {
      container_registry_name     = var.dev_container_registry_name
      container_registry_username = var.dev_container_registry_username
      container_registry_password = var.dev_container_registry_password
      prefix                      = "dev"
    }
    stg = {
      container_registry_name     = var.dev_container_registry_name
      container_registry_username = var.dev_container_registry_username
      container_registry_password = var.dev_container_registry_password
      prefix                      = "dev"
    }
    prd = {
      container_registry_name     = var.dev_container_registry_name
      container_registry_username = var.dev_container_registry_username
      container_registry_password = var.dev_container_registry_password
      prefix                      = "dev"
    }
  }
}

resource "kubernetes_secret" "registry" {
  for_each = toset(var.environments)
  metadata {
    name      = "docker-cfg"
    namespace = each.value
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        (local.registry[each.value].container_registry_name) = {
          "username" = local.registry[each.value].container_registry_username
          "password" = local.registry[each.value].container_registry_password
          "auth"     = base64encode("${local.registry[each.value].container_registry_username}:${local.registry[each.value].container_registry_password}")
        }
      }
    })
  }
}