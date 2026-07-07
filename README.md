# Personal Kubernetes Cluster

Helm-based project for managing a personal Kubernetes cluster with namespace-based environment separation.

All images are pulled from `ghcr.io/thanhleothanh/<project>:latest`.

## Architecture

```
charts/
├── infra/
│   └── secret-store/           # ClusterSecretStore (external-secrets)
└── apps/
    └── namespace/              # Apps — deployed PER namespace (dev, staging, ...)

environments/
├── azure-aks/
│   ├── infra/
│   │   ├── ingress-controller-values.yaml
│   │   └── secret-store-values.yaml
│   └── apps/
│       └── dev/
│           └── values.yaml
└── self-hosted/
    ├── infra/
    │   ├── ingress-controller-values.yaml
    │   └── secret-store-values.yaml
    └── apps/
        └── dev/
            └── values.yaml
```

**Deployment order:**

| Step | What | How |
|------|------|-----|
| 0 | HashiCorp Vault *(if self-hosted)* | Official Helm chart |
| 1 | External Secrets Operator | Official Helm chart |
| 2 | ClusterSecretStore | `charts/infra/secret-store` |
| 3 | Traefik ingress controller | Official chart: `traefik/traefik` |
| 4 | Namespace apps | `charts/apps/namespace` |

## Prerequisites

### Install Vault and set up auth (if self-hosted)

```bash
helm repo add hashicorp https://helm.releases.hashicorp.com
helm upgrade --install vault hashicorp/vault \
  -n vault --create-namespace \
  --set server.dev.enabled=true \
  --set injector.enabled=false
  
kubectl exec vault-0 -n vault -- vault auth enable kubernetes                                                                          

kubectl exec vault-0 -n vault -- vault write auth/kubernetes/config kubernetes_host=https://kubernetes.default.svc:443

echo 'path "secret/data/*" { capabilities = ["read"] }' | \
  kubectl exec -i vault-0 -n vault -- vault policy write secret-reader -

kubectl exec vault-0 -n vault -- vault write auth/kubernetes/role/cluster-secret-store-role \
  bound_service_account_names=external-secrets \
  bound_service_account_namespaces=external-secrets \
  policies=secret-reader \
  ttl=720h
```

### Create secrets in Vault

Secrets follow the convention `{namespace}/{secret-name}`:
```bash
kubectl exec vault-0 -n vault -- vault kv put secret/dev/db-secret \
  DB_URL='jdbc:postgresql://host.docker.internal:5432/demo' \
  DB_USERNAME=postgres \
  DB_PASSWORD=postgres
```

## Step-by-Step

### 1. Install External Secrets Operator

```bash
helm repo add external-secrets https://charts.external-secrets.io
helm upgrade --install external-secrets external-secrets/external-secrets \
  -n external-secrets --create-namespace \
  --wait
```

### 2. Deploy ClusterSecretStore

```bash
helm upgrade --install secret-store charts/infra/secret-store \
  -n external-secrets \
  -f environments/self-hosted/infra/secret-store-values.yaml \
  --wait
```

### 3. Deploy Traefik ingress controller

```bash
helm repo add traefik https://traefik.github.io/charts
helm upgrade --install traefik traefik/traefik \
  -n traefik --create-namespace \
  -f environments/self-hosted/infra/ingress-controller-values.yaml \
  --wait
```

### 4. Deploy apps to dev namespace

```bash
helm upgrade --install dev-apps charts/apps/namespace \
  -n dev --create-namespace \
  -f environments/self-hosted/apps/dev/values.yaml \
  --wait
```

The namespace chart creates `ExternalSecret` resources for each `secret.refs` entry that has a `remoteRef`. Vault secrets follow the convention `secret/{namespace}/{secret-name}`, so `remoteRef.key` should include the namespace prefix:

```yaml
secret:
  storeRef:
    name: cluster-secret-store
  refreshInterval: 1m
  refs:
    - name: db-secret              # K8s Secret name
      remoteRef:
        key: dev/db-secret         # Vault path: secret/dev/db-secret

apps:
  myapp:
    enabled: true
    secretRefs:
      - name: db-secret            # references the K8s Secret above
    configMapRefs:
      - name: app-configmap
```

Azure Key Vault doesn't support `/` in secret names. Use flat keys like `db-secret` when using AKV as the backend.

## Adding a New Environment

1. Create `environments/<env>/infra/` with provider config and ingress settings
2. Create `environments/<env>/apps/<namespace>/values.yaml`
3. Create secrets at `secret/{namespace}/{secret-name}`
4. Deploy infra, then namespace

## Adding a New App

Add under `apps:` in the namespace values.yaml:

```yaml
apps:
  myapp:
    enabled: true
    image:
      repository: ghcr.io/thanhleothanh/myapp
      tag: latest
    replicaCount: 1
    configMapRefs:
      - name: app-config
    secretRefs:
      - name: db-secret
    service:
      port: 8080
    ingress:
      enabled: true
      hosts:
        - host: myapp.dev.local
          paths:
            - path: /
              pathType: Prefix
```

Secrets must be declared in `secret.refs` at the namespace level. The `remoteRef.key` must match the full path in your secret backend.
