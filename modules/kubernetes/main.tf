terraform {
  required_version = ">=1.3"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "=2.19.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "=3.4.3"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.9.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "kubernetes_namespace" "namespace" {
  for_each = toset(var.environments)
  metadata {
    name = each.value
  }
}