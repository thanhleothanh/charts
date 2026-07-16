variable "environment" {
  type    = string
  default = "dev"
}

variable "location" {
  type    = string
  default = "indonesiacentral"
}

variable "cluster_name" {
  type    = string
  default = "personal-cluster"
}

variable "postgres_name" {
  type    = string
  default = "personal-cluster-postgres"
}

variable "mongo_name" {
  type    = string
  default = "personal-cluster-mongodb"
}

variable "vault_name" {
  type    = string
  default = "personal-cluster-vault"
}

variable "servicebus_name" {
  type    = string
  default = "personal-cluster-asb"
}

variable "tenant_id" {
  type        = string
  description = "Azure AD tenant ID. Required for Key Vault. Set in terraform.tfvars."
}

variable "tags" {
  type    = map(string)
  default = {}
}
