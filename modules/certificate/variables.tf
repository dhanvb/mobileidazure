variable "resource_group_name" {
  type        = string
  description = "Resources' group name."
}

variable "resource_group_location" {
  type        = string
  description = "Resources' group location."
}

variable "cluster_oidc_issuer_url" {
  type        = string
  description = "Cluster's open id connect url."
}

variable "aks_host" {
  type        = string
  description = "Kubernetes cluster host."
}

variable "aks_client_certificate" {
  type        = string
  description = "Kubernetes cluster client certificate."
}

variable "aks_client_key" {
  type        = string
  description = "Kubernetes cluster client key."
}

variable "aks_cluster_ca_certificate" {
  type        = string
  description = "Kubernetes cluster ca certificate."
}

variable "letsencrypt_email" {
  type    = string
  default = "p-mobileid@vision-box.com"
}

variable "letsencrypt_server" {
  default     = "https://acme-v02.api.letsencrypt.org/directory"
  description = "The Let's Encrypt server to use"
  validation {
    condition     = contains(["https://acme-staging-v02.api.letsencrypt.org/directory", "https://acme-v02.api.letsencrypt.org/directory"], var.letsencrypt_server)
    error_message = "Unknown value"
  }
}

variable "dns" {
  description = "Base domain"
}

variable "environments" {
  type        = list(string)
  description = "Environments."
}

variable "dns_zone_ingress_ids" {
  type        = map(string)
  description = "Cluster ingress object."
}
