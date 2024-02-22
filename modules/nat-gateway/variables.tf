variable "environments" {
  type        = list(string)
  description = "The type of environment: staging, qa, production, etc."
}

variable "resource_group_name" {
  type        = string
  description = "Resources' group name."
}

variable "region" {
  type        = string
  description = "Database's region."
}

variable "subnet_id" {
  type        = string
  description = "Cluster's subnet."
}