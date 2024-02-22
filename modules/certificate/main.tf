terraform {
  required_version = ">=1.3"
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.9.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "=2.19.0"
    }
  }

}

data "azurerm_client_config" "current" {
}