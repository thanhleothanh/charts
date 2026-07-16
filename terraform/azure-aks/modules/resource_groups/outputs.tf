output "web_name" {
  description = "Name of the web resource group (holds AKS)."
  value       = azurerm_resource_group.web.name
}

output "shared_name" {
  description = "Name of the shared resource group (holds Key Vault, Service Bus, private DNS)."
  value       = azurerm_resource_group.shared.name
}

output "database_name" {
  description = "Name of the database resource group (holds Postgres, Mongo)."
  value       = azurerm_resource_group.database.name
}

output "location" {
  value = var.location
}
