output "web_vnet_id" {
  description = "ID of the web VNet (where AKS lives); used to link private DNS zones."
  value       = azurerm_virtual_network.web.id
}

output "aks_subnet_id" {
  description = "Subnet in the web VNet where AKS nodes are deployed."
  value       = azurerm_subnet.aks.id
}

output "db_subnet_id" {
  description = "Subnet in the database VNet for private endpoints."
  value       = azurerm_subnet.database_pe.id
}

output "shared_subnet_id" {
  description = "Subnet in the shared VNet for private endpoints."
  value       = azurerm_subnet.shared_pe.id
}
