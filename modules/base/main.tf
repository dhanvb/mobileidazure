terraform {
  required_version = ">=1.3"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "=3.4.3"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.52.0"
    }
  }
}

locals {
  is_multi_environment = length(var.environments) > 1
}
