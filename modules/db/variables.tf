variable "resource_group_name" {
  type        = string
  description = "Resources' group name."
}

variable "db_server" {
  type        = string
  description = "DB server name."
}

variable "environments" {
  type        = list(string)
  description = "The type of environment: staging, qa, production, etc."
}