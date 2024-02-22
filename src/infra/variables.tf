locals {
  config               = yamldecode(file("../variables.yml"))
  regions              = local.config.regions
  is_multi_environment = length(var.environments) > 1
  region               = local.is_multi_environment ? local.regions["stg"] : local.regions[var.environments[0]]
}

variable "container_registry_name" {
  type        = string
  description = "Azure artifact's registry name"
}

variable "container_registry_username" {
  type        = string
  description = "Azure artifact's registry username"
}

variable "container_registry_password" {
  type        = string
  description = "Azure artifact's registry's password. This is set via environment variable."
  sensitive   = true
}

variable "admin_ssh_key_data" {
  type        = string
  description = "The ssh key for lunux profile."
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
