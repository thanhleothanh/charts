module "resource_groups" {
  source     = "../modules/resource_groups"
  environment = var.environment
  location    = var.location
  tags        = var.tags
}

module "networking" {
  source           = "../modules/networking"
  location         = var.location
  rg_web_name      = module.resource_groups.web_name
  rg_database_name = module.resource_groups.database_name
  rg_shared_name   = module.resource_groups.shared_name
  tags             = var.tags
}

module "aks" {
  source              = "../modules/aks"
  resource_group_name = module.resource_groups.web_name
  location            = var.location
  cluster_name        = var.cluster_name
  vnet_subnet_id      = module.networking.aks_subnet_id
  tags                = var.tags
}

module "database" {
  source                = "../modules/database"
  resource_group_name   = module.resource_groups.database_name
  location              = var.location
  postgres_name         = var.postgres_name
  mongo_name            = var.mongo_name
  subnet_id             = module.networking.db_subnet_id
  web_vnet_id           = module.networking.web_vnet_id
  tags                  = var.tags
}

module "shared" {
  source                = "../modules/shared"
  resource_group_name   = module.resource_groups.shared_name
  location              = var.location
  vault_name            = var.vault_name
  servicebus_name       = var.servicebus_name
  subnet_id             = module.networking.shared_subnet_id
  web_vnet_id           = module.networking.web_vnet_id
  tenant_id                     = var.tenant_id
  aks_kubelet_object_id = module.aks.kubelet_object_id
  aks_cluster_principal_id = module.aks.principal_id
  tags                        = var.tags
}
