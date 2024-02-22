variable "client" {
  type        = string
  description = "Client's name."
}

variable "cloudamqp_apikey" {
  type        = string
  description = "Api key to connect to AMQP Clolud."
}

variable "cloudamq_instances" {
  type = list(object({
    env : string
    plan : string
  }))
  description = "Instance names for CloudAMQP instances."
}

variable "cloudamq_region" {
  type        = string
  description = "Instances region."
}

variable "environment" {
  type        = string
  description = "The type of environment: staging, qa, production, etc."
}
