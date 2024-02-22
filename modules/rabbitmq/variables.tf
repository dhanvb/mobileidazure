variable "cloudamqp_endpoint" {
  type        = string
  description = "CloudAMQP endpoint."
}

variable "cloudamqp_credentials" {
  type        = map(string)
  description = "CloudAMQP password."
}

variable "cloudamqp_settings" {
  type = object({
    exchanges = list(object({
      name     = string
      username = optional(string)
      password = optional(string)
      settings = object({
        type        = string
        durable     = bool
        auto_delete = bool
      })
    }))
    queues : list(object({
      name     = string
      username = optional(string)
      password = optional(string)
      settings = object({
        durable     = bool
        auto_delete = bool
      })
    }))
    bindings : list(object({
      source           = string
      username         = optional(string)
      password         = optional(string)
      destination      = string
      destination_type = string
      routing_key      = string
    }))
  })
  description = "Reources configurations."
}

variable "cloudamqp_instance_provider_data" {
  type = map(object({
    instance_id = string
    env         = string
    username    = string
    password    = string
    vhost       = string
  }))
}

variable "environment" {
  type        = string
  description = "The type of environment: staging, qa, production, etc."
}
