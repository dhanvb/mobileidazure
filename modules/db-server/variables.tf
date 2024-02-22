variable "region" {
  type        = string
  description = "Database's region."
}

variable "resource_group_name" {
  type        = string
  description = "Resources' group name."
}

variable "postgres_version" {
  type        = number
  description = "Database's postgres version. Major versions only."
}

variable "high_availability" {
  type        = bool
  description = "A boolean indicating if the database should use high availability or not."
}

variable "storage_size" {
  type        = number
  description = "The size of the data disk, in GB."
}

variable "sku" {
  type        = string
  description = "Specifies the SKU Name for the db server."
}

variable "subnet_id" {
  type        = string
  description = "The subnet id for the AKS cluster."
}

variable "backup_retention_days" {
  type        = number
  description = "Backup retention days for the server."

  validation {
    condition     = var.backup_retention_days >= 7 && var.backup_retention_days <= 35
    error_message = "Must be between 7 and 35."
  }
}

variable "environments" {
  type        = list(string)
  description = "The type of environment: staging, qa, production, etc."
}
