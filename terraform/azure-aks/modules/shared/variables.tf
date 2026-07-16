variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vault_name" {
  type = string
}

variable "servicebus_name" {
  type = string
}

variable "subnet_id" {
  type        = string
  description = "Subnet for the Key Vault private endpoint (shared VNet)."
}

variable "web_vnet_id" {
  type        = string
  description = "Web VNet ID (where AKS lives); vault DNS zone links here so AKS resolves."
}

variable "tenant_id" {
  type = string
}

variable "aks_kubelet_object_id" {
  type        = string
  description = "AKS kubelet identity object ID (personal-cluster-agentpool), granted Secrets User on the vault."
}

variable "aks_cluster_principal_id" {
  type        = string
  description = "AKS cluster system-assigned identity principal ID (personal-cluster), granted Secrets User on the vault."
}

variable "servicebus_sku" {
  type    = string
  default = "Standard"
}

variable "tags" {
  type    = map(string)
  default = {}
}
