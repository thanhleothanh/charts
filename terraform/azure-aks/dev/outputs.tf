output "aks_kube_config" {
  value     = module.aks.kube_config_raw
  sensitive = true
}

output "key_vault_uri" {
  value = module.shared.vault_uri
}

output "postgres_fqdn" {
  value = module.database.postgres_fqdn
}

output "postgres_admin" {
  value = module.database.postgres_admin
}

output "postgres_password" {
  value     = module.database.postgres_password
  sensitive = true
}

output "mongo_connection_string" {
  value     = module.database.mongo_connection_string
  sensitive = true
}

output "mongo_username" {
  value = module.database.mongo_username
}

output "servicebus_endpoint" {
  value = module.shared.servicebus_endpoint
}
