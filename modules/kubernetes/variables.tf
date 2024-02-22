variable "client" {
  type        = string
  description = "Client's name. No spaces allowed."
}

variable "environments" {
  type        = list(string)
  description = "The type of environment: staging, qa, production, etc."
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
  description = "Azure storage's account name. This is set via environment variable."
  sensitive   = true
}

variable "azure_storage_account_key" {
  type        = string
  description = "Azure storage's account key. This is set via environment variable."
  sensitive   = true
}

variable "liveness_api_key" {
  type        = string
  description = "Liveness' api key. This is set via environment variable."
  sensitive   = true
}

variable "liveness_replicas" {
  type        = number
  description = "Number of liveness pod's replicas."
}

variable "liveness_version" {
  type        = string
  description = "Liveness' image version."
}

variable "db_address" {
  type        = string
  description = "Database's address."
}

variable "db_ip_address" {
  type        = string
  description = "Database's ip address."
}

variable "keycloak_version" {
  type        = string
  description = "Keycloak's image version."
}

variable "gateway_replicas" {
  type        = number
  description = "Number of gateway pod's replicas."
}

variable "gateway_version" {
  type        = string
  description = "Gateway's image version."
}

variable "backoffice_version" {
  type        = string
  description = "Backoffice's image version."
}

variable "match_service_address" {
  type        = string
  description = "Match service URL."
}

variable "resource_group" {
  type        = string
  description = "Resources' group name."
}

variable "resource_group_location" {
  type        = string
  description = "Resources' group location."
}

variable "cluster_oidc_issuer_url" {
  type        = string
  description = "Cluster's issuer url."
}

variable "dns_zone_ingress_ids" {
  type        = map(string)
  description = "Cluster's ingress id."
}

variable "dns" {
  type        = string
  description = "Base domain"
}

variable "backoffice_dns_name" {
  type        = string
  description = "Backoffice domain name application"
}

variable "gateway_dns_name" {
  type        = string
  description = "API Gateway domain name application"
}

variable "keycloak_dns_name" {

  type        = string
  description = "Keycloak domain name application"
}

variable "keycloak_env" {
  type        = string
  description = "Unique keycloak's environment - usualy will be staging."
}

variable "liveness_env" {
  type        = string
  description = "Unique liveness's environment - usualy will be staging."
}

variable "cluster_issuer_name" {
  type        = string
  description = "Default cluster certificate issuer name."
}

variable "cert_manager_namespace" {
  type        = string
  description = "Certificate manager namespace."
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

variable "subjects_data_flow_injection_credentials" {
  type        = string
  description = "Sets data flow injection url according to its env."
}
