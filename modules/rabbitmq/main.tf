terraform {
  required_version = ">=1.3"
  required_providers {
    rabbitmq = {
      source  = "cyrilgdn/rabbitmq"
      version = "=1.8.0"
    }
  }
}

locals {
  vhost = var.cloudamqp_instance_provider_data[var.environment].username
}

provider "rabbitmq" {
  endpoint = var.cloudamqp_endpoint
  username = var.cloudamqp_instance_provider_data[var.environment].username
  password = var.cloudamqp_instance_provider_data[var.environment].password
}
