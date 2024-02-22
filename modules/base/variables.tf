variable "client" {
  type        = string
  description = "Client's name. No spaces allowed."
}

variable "region" {
  type        = string
  description = "Project's region. Check Azure's available regions and fill the default value."
}

variable "environments" {
  type        = list(string)
  description = "The type of environment: staging, qa, production, etc."
}

variable "cluster_principal_id" {
  type        = string
  description = "Cluster's id."
}