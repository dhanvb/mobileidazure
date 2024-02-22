terraform {
  required_version = ">=1.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.52.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "=2.37.1"
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = var.aks_host
    client_certificate     = base64decode(var.aks_client_certificate)
    client_key             = base64decode(var.aks_client_key)
    cluster_ca_certificate = base64decode(var.aks_cluster_ca_certificate)
  }
}

data "azuread_client_config" "current" {
}

data "azurerm_client_config" "current" {
}

resource "azurerm_dns_zone" "ingress" {
  for_each            = toset(var.environments)
  resource_group_name = var.resource_group
  name                = "${each.value}.${var.dns}"
}