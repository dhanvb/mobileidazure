terraform {
  required_version = ">=1.3"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "=2.19.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.9.0"
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