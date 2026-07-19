data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}

resource "azurerm_key_vault" "this" {
  name                          = var.vault_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tenant_id                     = var.tenant_id
  sku_name                      = var.vault_sku_name
  public_network_access_enabled = var.vault_public_network_access_enabled
  purge_protection_enabled      = var.vault_purge_protection_enabled
  rbac_authorization_enabled     = true
  tags                          = var.tags
}

data "azurerm_role_definition" "secrets_user" {
  name = "Key Vault Secrets User"
}

data "azurerm_role_definition" "secrets_officer" {
  name = "Key Vault Secrets Officer"
}

resource "azurerm_role_assignment" "deployer" {
  scope                = azurerm_key_vault.this.id
  role_definition_id   = "${data.azurerm_subscription.current.id}${data.azurerm_role_definition.secrets_officer.id}"
  principal_id         = data.azurerm_client_config.current.object_id
  principal_type       = "User"
}

resource "azurerm_role_assignment" "aks_agentpool" {
  scope              = azurerm_key_vault.this.id
  role_definition_id = "${data.azurerm_subscription.current.id}${data.azurerm_role_definition.secrets_user.id}"
  principal_id       = var.aks_kubelet_object_id
  principal_type     = "ServicePrincipal"
}

resource "azurerm_role_assignment" "aks_cluster" {
  scope              = azurerm_key_vault.this.id
  role_definition_id = "${data.azurerm_subscription.current.id}${data.azurerm_role_definition.secrets_user.id}"
  principal_id       = var.aks_cluster_principal_id
  principal_type     = "ServicePrincipal"
}

# Private DNS zone (in this RG) linked to the web VNet so AKS resolves privately
resource "azurerm_private_dns_zone" "vault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "vault_aks" {
  name                  = "vault-to-web"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.vault.name
  virtual_network_id    = var.web_vnet_id
}

resource "azurerm_private_endpoint" "vault" {
  name                = "${var.vault_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.vault_name}-psc"
    private_connection_resource_id = azurerm_key_vault.this.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "vault-dns"
    private_dns_zone_ids = [azurerm_private_dns_zone.vault.id]
  }
}

resource "azurerm_servicebus_namespace" "this" {
  name                          = var.servicebus_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku                           = var.servicebus_sku
  public_network_access_enabled = var.servicebus_public_network_access_enabled
  tags                          = var.tags
}
