variable "dns" {
  type        = string
  description = "Base domain"
}

variable "environments" {
  type        = list(string)
  description = "Environments."
}

variable "resource_group" {
  description = "Resource group name."
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
