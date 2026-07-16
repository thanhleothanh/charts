# Terraform — Azure infrastructure

Deploys the `personal-cluster` Azure infrastructure with Terraform (local state, run locally).

## Layout
```
terraform/azure-aks/
  modules/            # reusable: resource_groups, aks, networking, database, shared
  dev/                # environment wiring (local backend)
```

## Resources created (env = dev)
- Each resource group owns its own VNet: `vnet-rg-dev-web` (AKS subnet), `vnet-rg-dev-database` (pe-subnet), `vnet-rg-dev-shared` (pe-subnet). Peering: web↔database, web↔shared.
- `rg-dev-web` — AKS cluster `personal-cluster` deployed into the web VNet subnet (no auto MC_ VNet).
- `rg-dev-database` — Postgres `personal-cluster-postgres` + private endpoint, Azure DocumentDB MongoDB vCore cluster `personal-cluster-mongodb` + private endpoint
- `rg-dev-shared` — Key Vault `personal-cluster-vault` + private endpoint, Service Bus `personal-cluster` (public access)
- Private DNS zones co-located with each service (postgres/mongo in rg-dev-database, vault in rg-dev-shared), each linked to the web VNet so AKS resolves them privately.

## Deploy
```bash
# remember to add tenant_id to terraform.tfvars
terraform init
terraform plan
terraform apply
```
