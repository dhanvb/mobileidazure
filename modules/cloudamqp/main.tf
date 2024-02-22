terraform {
  required_version = ">=1.3"
  required_providers {
    cloudamqp = {
      source  = "cloudamqp/cloudamqp"
      version = "=1.27.0"
    }
  }
}

provider "cloudamqp" {
  apikey                         = var.cloudamqp_apikey
  enable_faster_instance_destroy = true
}