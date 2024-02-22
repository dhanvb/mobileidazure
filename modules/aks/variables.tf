variable "region" {
  type        = string
  description = "Kubernetes cluster's region."
}

variable "client" {
  type        = string
  description = "Client's name. No spaces allowed."
}

variable "resource_group_name" {
  type        = string
  description = "Resources' group name."
}

variable "linux_node_count" {
  type        = number
  description = "Linux node pool's node count"

  validation {
    condition     = var.linux_node_count >= 1
    error_message = "Must be 1 or more."
  }
}

variable "linux_vm_size" {
  type        = string
  description = "Linux node vm size"
}

variable "windows_node_count" {
  type        = number
  description = "Windows node pool's node count"

  validation {
    condition     = var.windows_node_count >= 1
    error_message = "Must be 1 or more."
  }
}

variable "windows_vm_size" {
  type        = string
  description = "Windows node vm size"
}

variable "dns_prefix" {
  type        = string
  description = "DNS prefix specified when creating the managed cluster."
}

variable "analytics_workspace_id" {
  type        = string
  description = "The ID of the Log Analytics Workspace."
}

variable "admin_ssh_key_data" {
  type        = string
  description = "The ssh key for linux profile."
}

variable "environments" {
  type        = list(string)
  description = "The type of environment: staging, qa, production, etc."
}

variable "subnet_id" {
  type        = string
  description = "Cluster's subnet id."
}

variable "subnet_scope" {
  type        = string
  description = "Cluster's subnet scope."
}

