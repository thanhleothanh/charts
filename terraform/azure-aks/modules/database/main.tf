resource "random_password" "postgres" {
  length  = 24
  special = true
}

resource "azurerm_postgresql_flexible_server" "this" {
  name                          = var.postgres_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = var.postgres_version
  sku_name                      = var.postgres_sku
  storage_mb                    = var.postgres_storage_mb
  public_network_access_enabled = var.postgres_public_network_access_enabled
  administrator_login           = var.postgres_administrator_login
  administrator_password        = random_password.postgres.result
  tags                          = var.tags

  lifecycle {
    ignore_changes = [zone]
  }
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "azure_services" {
  name             = "AllowAllAzureServicesAndResourcesWithinAzureIps"
  server_id        = azurerm_postgresql_flexible_server.this.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Private DNS zones (in this RG) linked to the web VNet so AKS resolves privately
resource "azurerm_private_dns_zone" "postgres" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres_aks" {
  name                  = "postgres-to-web"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = var.web_vnet_id
}

resource "azurerm_private_endpoint" "postgres" {
  name                = "${var.postgres_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.postgres_name}-psc"
    private_connection_resource_id = azurerm_postgresql_flexible_server.this.id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "postgres-dns"
    private_dns_zone_ids = [azurerm_private_dns_zone.postgres.id]
  }
}

resource "random_password" "mongo" {
  length  = 24
  special = true
}

resource "azurerm_mongo_cluster" "this" {
  name                     = var.mongo_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  administrator_username   = var.mongo_administrator_username
  administrator_password   = random_password.mongo.result
  compute_tier             = var.mongo_compute_tier
  high_availability_mode   = var.mongo_high_availability_mode
  shard_count              = var.mongo_shard_count
  storage_size_in_gb       = var.mongo_storage_size_in_gb
  version                  = var.mongo_version
  public_network_access    = var.mongo_public_network_access
  tags                     = var.tags
}

resource "azurerm_mongo_cluster_firewall_rule" "azure_services" {
  name             = "AllowAllAzureServicesAndResourcesWithinAzureIps"
  mongo_cluster_id = azurerm_mongo_cluster.this.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_private_dns_zone" "mongo" {
  name                = "privatelink.mongocluster.cosmos.azure.com"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "mongo_aks" {
  name                  = "mongo-to-web"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.mongo.name
  virtual_network_id    = var.web_vnet_id
}

resource "azurerm_private_endpoint" "mongo" {
  name                = "${var.mongo_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.mongo_name}-psc"
    private_connection_resource_id = azurerm_mongo_cluster.this.id
    subresource_names              = ["MongoCluster"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "mongo-dns"
    private_dns_zone_ids = [azurerm_private_dns_zone.mongo.id]
  }
}
