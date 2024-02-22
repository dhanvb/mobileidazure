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
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "=2.37.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.9.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.52.0"
    }
  }

  backend "http" {
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
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

provider "kubernetes" {
  host                   = var.aks_host
  username               = var.aks_username
  password               = var.aks_password
  client_certificate     = base64decode(var.aks_client_certificate)
  client_key             = base64decode(var.aks_client_key)
  cluster_ca_certificate = base64decode(var.aks_cluster_ca_certificate)
}

provider "kubectl" {
  load_config_file       = false
  host                   = var.aks_host
  client_certificate     = base64decode(var.aks_client_certificate)
  client_key             = base64decode(var.aks_client_key)
  cluster_ca_certificate = base64decode(var.aks_cluster_ca_certificate)
}

