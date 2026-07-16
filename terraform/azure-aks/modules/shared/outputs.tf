output "vault_uri" {
  value = azurerm_key_vault.this.vault_uri
}

output "servicebus_endpoint" {
  value = azurerm_servicebus_namespace.this.endpoint
}
