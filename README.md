# Personal Kubernetes Cluster

Helm-based project for managing a personal Kubernetes cluster with namespace-based environment separation.

All images are pulled from `ghcr.io/thanhleothanh/<project>:latest`.

## Architecture

```
charts/
├── cluster/              # Shared infra (ingress-controller) — deployed ONCE per cluster
├── ingress-controller/   # Traefik ingress controller
└── namespace/            # Apps — deployed PER namespace (dev, staging, ...)

environments/
└── self-hosted/
    ├── cluster-values.yaml      # shared infra overrides (NodePort, replicaCount)
    └── dev/
        └── values.yaml          # dev apps, config, secrets
```

**Two-tier deployment:**
1. `cluster-deploy` — installs Traefik ingress controller (shared across all namespaces)
2. `namespace-deploy` — installs apps into a specific namespace

Each namespace gets its own resource quotas, app versions, ingress hosts, ConfigMap, and Secrets.

## Step-by-Step: Bring Up the Application

### 1. Deploy cluster infrastructure (Traefik)

```bash
helm upgrade --install personal-cluster charts/cluster \
  -n default \
  -f environments/self-hosted/cluster-values.yaml \
  --wait
```

### 2. Deploy apps to dev namespace

```bash
helm upgrade --install dev-apps charts/namespace \
  -n dev --create-namespace \
  -f environments/self-hosted/dev/values.yaml \
  --set validations.verifyRefs=true
  --wait
```

## Teardown

```bash
# Remove apps
helm uninstall dev-apps -n dev
kubectl delete namespace dev

# Remove cluster infra
helm uninstall personal-cluster -n default
```

## Adding a New Env/Namespace

1. Create directory: `environments/<env>/<namespace>/`
2. Copy an existing values.yaml as a template
3. Customize apps, tags, hosts, configMap, secrets. Remember to create secret per ref beforehand
4. Deploy: `helm upgrade --install <namespace>-apps charts/namespace -n <namespace> --create-namespace -f environments/self-hosted/<namespace>/values.yaml`

## Adding a New App

Edit the namespace values.yaml and add under `apps:`:

```yaml
apps:
  myapp:
    enabled: true
    image:
      repository: ghcr.io/thanhleothanh/myapp
      tag: latest
    replicaCount: 1
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
