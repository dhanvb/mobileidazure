terraform {
  required_version = ">=1.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.52.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "=3.4.3"
    }
  }
}

locals {
  is_multi_environment = length(var.environments) > 1
}

data "azurerm_subscription" "current" {
}