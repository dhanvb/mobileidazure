locals {
  config             = yamldecode(file("../variables.yml"))
  cloudamqp_settings = yamldecode(file("../../resources/rabbitmq-config.yml"))
}

variable "cloudamqp_apikey" {
  type        = string
  description = "Api key to connect to AMQP Clolud."
}

variable "cloudamqp_endpoint" {
  type        = string
  description = "CloudAMQP administrative endpoint."
}

variable "environments" {
  type        = list(string)
  description = "The type of environment: dev, qa and/or stg."
  default     = ["dev"]
  validation {
    condition = length([
      for env in var.environments : env
      if can(regex("^dev|qa|stg|prd$", env))
    ]) == length(var.environments)
    error_message = "Invalid value for environments configuration. Allowed ones: dev, qa or stg."
  }
}