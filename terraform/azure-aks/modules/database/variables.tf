variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "postgres_name" {
  type = string
}

variable "mongo_name" {
  type = string
}

variable "subnet_id" {
  type        = string
  description = "Subnet for the private endpoints (database VNet)."
}

variable "web_vnet_id" {
  type        = string
  description = "Web VNet ID (where AKS lives); private DNS zones link here so AKS resolves."
}

variable "postgres_version" {
  type    = string
  default = "16"
}

variable "postgres_sku" {
  type    = string
  default = "B_Standard_B1ms"
}

variable "postgres_storage_mb" {
  type    = number
  default = 32768
}

variable "postgres_administrator_login" {
  type    = string
  default = "pgadmin"
}

variable "postgres_public_network_access_enabled" {
  type    = bool
  default = true
}

variable "mongo_administrator_username" {
  type    = string
  default = "mongoadmin"
}

variable "mongo_public_network_access" {
  type    = string
  default = "Enabled"
}

variable "mongo_compute_tier" {
  type    = string
  default = "M10"
}

variable "mongo_high_availability_mode" {
  type    = string
  default = "Disabled"
}

variable "mongo_shard_count" {
  type    = string
  default = "1"
}

variable "mongo_storage_size_in_gb" {
  type    = string
  default = "32"
}

variable "mongo_version" {
  type    = string
  default = "7.0"
}

variable "tags" {
  type    = map(string)
  default = {}
}
