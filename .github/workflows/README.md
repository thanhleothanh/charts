# CD Workflow: Deploy to Azure AKS

GitHub Actions workflow for deploying Helm charts to Azure AKS.

## Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `env` | Yes | — | Target namespace: `dev`, `staging`, `prod` |
| `resource_group` | Yes | `apps` | Azure resource group |
| `cluster_name` | Yes | `personal-cluster` | AKS cluster name |
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