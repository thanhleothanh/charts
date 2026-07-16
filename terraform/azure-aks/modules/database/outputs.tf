output "postgres_fqdn" {
  value = azurerm_postgresql_flexible_server.this.fqdn
}

output "postgres_admin" {
  value = azurerm_postgresql_flexible_server.this.administrator_login
}

output "postgres_password" {
  value     = random_password.postgres.result
  sensitive = true
}

output "mongo_connection_string" {
  value     = azurerm_mongo_cluster.this.connection_strings[0]
  sensitive = true
}

output "mongo_username" {
  value = azurerm_mongo_cluster.this.administrator_username
}
