# --- Web VNet (holds AKS nodes) ---
resource "azurerm_virtual_network" "web" {
  name                = "vnet-${var.rg_web_name}"
  location            = var.location
  resource_group_name = var.rg_web_name
  address_space       = [var.web_vnet_cidr]
  tags                = var.tags
}

resource "azurerm_subnet" "aks" {
  name                 = "aks-subnet"
  resource_group_name  = var.rg_web_name
  virtual_network_name = azurerm_virtual_network.web.name
  address_prefixes     = [var.aks_subnet_prefix]
}

# --- Database VNet (private endpoints for Postgres / Mongo) ---
resource "azurerm_virtual_network" "database" {
  name                = "vnet-${var.rg_database_name}"
  location            = var.location
  resource_group_name = var.rg_database_name
  address_space       = [var.db_vnet_cidr]
  tags                = var.tags
}

resource "azurerm_subnet" "database_pe" {
  name                                   = "pe-subnet"
  resource_group_name                    = var.rg_database_name
  virtual_network_name                   = azurerm_virtual_network.database.name
  address_prefixes                       = [var.db_subnet_prefix]
  private_endpoint_network_policies      = "Disabled"
}

# --- Shared VNet (private endpoints for Key Vault) ---
resource "azurerm_virtual_network" "shared" {
  name                = "vnet-${var.rg_shared_name}"
  location            = var.location
  resource_group_name = var.rg_shared_name
  address_space       = [var.shared_vnet_cidr]
  tags                = var.tags
}

resource "azurerm_subnet" "shared_pe" {
  name                                   = "pe-subnet"
  resource_group_name                    = var.rg_shared_name
  virtual_network_name                   = azurerm_virtual_network.shared.name
  address_prefixes                       = [var.shared_subnet_prefix]
  private_endpoint_network_policies      = "Disabled"
}

# --- VNet peering: web <-> db, web <-> shared (no db <-> shared) ---
resource "azurerm_virtual_network_peering" "web_db" {
  name                      = "web-to-db"
  resource_group_name       = var.rg_web_name
  virtual_network_name      = azurerm_virtual_network.web.name
  remote_virtual_network_id = azurerm_virtual_network.database.id
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "db_web" {
  name                      = "db-to-web"
  resource_group_name       = var.rg_database_name
  virtual_network_name      = azurerm_virtual_network.database.name
  remote_virtual_network_id = azurerm_virtual_network.web.id
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "web_shared" {
  name                      = "web-to-shared"
  resource_group_name       = var.rg_web_name
  virtual_network_name      = azurerm_virtual_network.web.name
  remote_virtual_network_id = azurerm_virtual_network.shared.id
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "shared_web" {
  name                      = "shared-to-web"
  resource_group_name       = var.rg_shared_name
  virtual_network_name      = azurerm_virtual_network.shared.name
  remote_virtual_network_id = azurerm_virtual_network.web.id
  allow_virtual_network_access = true
}
