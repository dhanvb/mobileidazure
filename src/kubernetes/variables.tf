locals {
  config               = yamldecode(file("../variables.yml"))
  regions              = local.config.regions
  is_multi_environment = length(var.environments) > 1
  region               = local.is_multi_environment ? local.regions["stg"] : local.regions[var.environments[0]]
}

# ENV VARIABLES
# ---------------------------------------------------
variable "liveness_api_key" {
  type        = string
  description = "Liveness' API key. This is set via env variable."
  sensitive   = true
}

variable "dev_container_registry_name" {
  type        = string
  description = "Azure artifact's registry name"
}

variable "dev_container_registry_username" {
  type        = string
  description = "Azure artifact's registry username"
}

variable "dev_container_registry_password" {
  type        = string
  description = "Azure artifact's registry's password. This is set via environment variable."
  sensitive   = true
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

variable "azure_storage_account_name" {
  type        = string
  description = "Azure storage account name. This is set via env variable."
  sensitive   = true
}

variable "azure_storage_account_key" {
  type        = string
  description = "Azure storage account key. This is set via env variable."
  sensitive   = true
}

variable "match_service_address" {
  type        = string
  description = "Match service URL."
}

variable "aks_host" {
  type        = string
  description = "This is set via environment variable."
  default     = ""
}

variable "aks_username" {
  type        = string
  description = "This is set via environment variable."
  default     = ""
}

variable "aks_password" {
  type        = string
  description = "This is set via environment variable."
  sensitive   = true
  default     = ""
}

variable "aks_client_certificate" {
  description = "This is set via environment variable."
  type        = string
  default     = ""
}

variable "aks_client_key" {
  description = "This is set via environment variable."
  type        = string
  default     = ""
}

variable "aks_cluster_ca_certificate" {
  description = "This is set via environment variable."
  type        = string
  default     = ""
}

variable "resource_group" {
  type        = string
  description = "Resources' group name."
}

variable "cluster_oidc_issuer_url" {
  type        = string
  description = "Cluster's issuer url."
}

variable "resource_group_location" {
  type        = string
  description = "Resources region"
}

# database import
variable "database_address" {
  type        = string
  description = "This is set via environment variable."
  default     = ""
}

variable "db_ip_address" {
  type        = string
  description = "This is set via environment variable."
}

variable "gateway_db" {
  type        = map(string)
  description = "Gateway's database."
}

variable "gateway_db_user" {
  type        = string
  description = "Gateway's database user."
}

variable "gateway_db_password" {
  type        = string
  description = "Gateway's database password."
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

variable "subjects_data_flow_injection_credentials" {
  type        = string
  description = "Sets data flow injection url according to its env."
}
