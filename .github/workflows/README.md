# CD Workflow: Deploy to Azure AKS

GitHub Actions workflow for deploying Helm charts to Azure AKS.

## Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `env` | Yes | — | Target namespace: `dev`, `staging`, `prod` |
| `resource_group` | Yes | `rg-dev-web` | Azure resource group |
| `cluster_name` | Yes | `personal-cluster` | AKS cluster name |

## Prerequisites

### 1. Manually create Azure AKS 

Remember info like `cluster_name`, `resource_group`

### 2. Create Service Principal

```bash
az ad sp create-for-rbac --name "personal-github-actions-login" --role contributor --scopes /subscriptions/<YOUR_SUBSCRIPTION_ID> --json-auth
```

Copy the entire JSON output.

### 3. Add GitHub Secret

**Settings → Secrets and variables → Actions → New repository secret**

| Secret Name | Value |
|-------------|-------|
| `AZURE_CREDENTIALS` | Paste the entire JSON output from step 1 |