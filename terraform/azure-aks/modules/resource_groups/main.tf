locals {
  rg_web      = "rg-${var.environment}-web"
  rg_shared   = "rg-${var.environment}-shared"
  rg_database = "rg-${var.environment}-database"
}

resource "azurerm_resource_group" "web" {
  name     = local.rg_web
  location = var.location
  tags     = var.tags
}

resource "azurerm_resource_group" "shared" {
  name     = local.rg_shared
  location = var.location
  tags     = var.tags
}

resource "azurerm_resource_group" "database" {
  name     = local.rg_database
  location = var.location
  tags     = var.tags
}
