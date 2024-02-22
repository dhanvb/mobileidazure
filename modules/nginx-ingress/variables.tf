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

variable "aks_subnet_id" {
  type        = string
  description = "ID of the AKS subnet."
}

variable "aks_node_resource_group_id" {
  type        = string
  description = "ID of the resource group containing AKS nodes."
}