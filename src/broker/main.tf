terraform {
  required_version = ">=1.3"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "=3.4.3"
    }
    cloudamqp = {
      source  = "cloudamqp/cloudamqp"
      version = "=1.27.0"
    }
    rabbitmq = {
      source  = "cyrilgdn/rabbitmq"
      version = "=1.8.0"
    }
  }

  backend "http" {
  }
}
