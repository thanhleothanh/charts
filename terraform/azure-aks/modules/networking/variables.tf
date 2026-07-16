variable "location" {
  type = string
}

variable "rg_web_name" {
  type = string
}

variable "rg_database_name" {
  type = string
}

variable "rg_shared_name" {
  type = string
}

variable "web_vnet_cidr" {
  type    = string
  default = "10.3.0.0/16"
}

variable "db_vnet_cidr" {
  type    = string
  default = "10.1.0.0/16"
}

variable "shared_vnet_cidr" {
  type    = string
  default = "10.2.0.0/16"
}

variable "aks_subnet_prefix" {
  type    = string
  default = "10.3.1.0/24"
}

variable "db_subnet_prefix" {
  type    = string
  default = "10.1.0.0/24"
}

variable "shared_subnet_prefix" {
  type    = string
  default = "10.2.0.0/24"
}

variable "tags" {
  type    = map(string)
  default = {}
}
