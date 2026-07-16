variable "resource_group_name" {
  type        = string
  description = "Resource group that will contain the AKS cluster."
}

variable "location" {
  type = string
}

variable "vnet_subnet_id" {
  type        = string
  description = "Existing subnet (in the web VNet) for the AKS node pool."
}

variable "cluster_name" {
  type = string
}

variable "dns_prefix" {
  type    = string
  default = null
}

variable "kubernetes_version" {
  type    = string
  default = "1.34"
}

variable "node_count" {
  type    = number
  default = 2
}

variable "node_vm_size" {
  type    = string
  default = "Standard_B2s_v2"
}

variable "tags" {
  type    = map(string)
  default = {}
}
