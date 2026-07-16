output "kubelet_object_id" {
  description = "Object ID of the AKS kubelet managed identity (used for Key Vault access)."
  value       = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}

output "principal_id" {
  description = "Principal ID of the AKS cluster system-assigned identity."
  value       = azurerm_kubernetes_cluster.this.identity[0].principal_id
}

output "kube_config_raw" {
  description = "Raw kubeconfig for the cluster."
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
}
