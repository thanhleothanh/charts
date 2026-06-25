# CD Workflow: Deploy to Azure AKS

GitHub Actions workflow for deploying Helm charts to Azure AKS.

## Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `env` | Yes | — | Target namespace: `dev` (environments/azure-aks/dev) | `resource_group` | Yes | `rg-dev-web` | Azure resource group |
| `resource_group` | Yes | `rg-dev-web` | AKS resource group on Azure AKS |
| `cluster_name` | Yes | `personal-cluster` | AKS cluster name on Azure AKS |
| `image_tags` | No | — | Image tags as JSON |

### Image Tags Format

Pass one or more app image tags as JSON:

```json
{"kotlin-spring": "a1b2c3d"}
```

```json
{"kotlin-spring": "a1b2c3d", "api-gateway": "e5f6g7h"}
```

Leave empty to deploy without changing image tags.

## Prerequisites

### 1. Create Service Principal

```bash
az ad sp create-for-rbac \
  --name "personal-github-actions-azure-aks" \
  --role "Azure Kubernetes Service Cluster User Role" \
  --scopes "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/apps/providers/Microsoft.ContainerService/managedClusters/personal-cluster"
```

### 2. Add GitHub Secrets

**Settings → Secrets and variables → Actions → New repository secret**

| Secret | Value |
|--------|-------|
| `AZURE_CLIENT_ID` | Service Principal `appId` |
| `AZURE_CLIENT_SECRET` | Service Principal `password` |
| `AZURE_TENANT_ID` | Your Azure AD tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Your Azure subscription ID |
