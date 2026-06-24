# Personal Kubernetes Cluster

Helm-based project for managing a personal Kubernetes cluster across multiple providers, with namespace-based environment separation.

All images are pulled from `ghcr.io/thanhleothanh/<project>:latest`.

## Architecture

```
charts/
├── cluster/              # Shared infra (ingress-controller) — deployed ONCE per cluster
├── ingress-controller/   # Traefik ingress controller
├── namespace/            # Apps — deployed PER namespace (dev, staging, ...)
├── monitoring/           # Prometheus + Grafana (placeholder)
└── databases/            # PostgreSQL + Redis (placeholder)

environments/
├── azure-aks/
│   ├── cluster-values.yaml      # shared infra overrides
│   ├── dev/
│   │   └── values.yaml          # dev apps, config, secrets
│   └── staging/
│       └── values.yaml          # staging apps, config, secrets
```

**Two-tier deployment:**
1. `cluster-deploy` — installs ingress-controller (shared across all namespaces)
2. `namespace-deploy` — installs apps into a specific namespace

Each namespace gets its own resource quotas, app versions, ingress hosts, ConfigMap, and Secrets.

## Supported Providers

| Provider | Config |
|----------|--------|
| AWS EKS | `environments/aws-eks/` |
| Azure AKS | `environments/azure-aks/` |
| Self-hosted | `environments/self-hosted/` |

## Quick Start

```bash
# 1. Deploy cluster infra (ingress-controller)
make cluster-deploy ENV=azure-aks

# 2. Deploy apps to dev namespace
make namespace-deploy ENV=azure-aks NS=dev

# 3. Deploy apps to staging namespace
make namespace-deploy ENV=azure-aks NS=staging

# All-in-one (cluster + one namespace)
make deploy-all ENV=azure-aks NS=dev

# Dry run
make dry-run-cluster ENV=azure-aks
make dry-run-namespace ENV=azure-aks NS=dev

# Lint everything
make lint

# Teardown
make teardown-namespace ENV=azure-aks NS=dev
make teardown-cluster ENV=azure-aks
make teardown-all ENV=azure-aks NS=dev
```

## Per-Namespace Configuration

Each namespace gets its own `values.yaml` with:

- **Which apps** are enabled/disabled
- **Image tags** (e.g., `latest` for dev, `v1.0.0` for staging)
- **Replica counts** (1 for dev, 2+ for staging)
- **Resource quotas** per namespace
- **Ingress hosts** (e.g., `app.dev.example.com` vs `app.staging.example.com`)
- **ConfigMap** — shared non-sensitive env vars for all apps
- **Secret** — shared sensitive env vars for all apps

Example dev vs staging:

```yaml
# environments/azure-aks/dev/values.yaml
namespace:
  name: dev
configMap:
  enabled: true
  data:
    APP_ENV: dev
    LOG_LEVEL: debug
secret:
  enabled: true
  data:
    DB_PASSWORD: devpassword123
apps:
  kotlin-spring:
    enabled: true
    image:
      tag: latest
    replicaCount: 1

# environments/azure-aks/staging/values.yaml
namespace:
  name: staging
configMap:
  enabled: true
  data:
    APP_ENV: staging
    LOG_LEVEL: info
secret:
  enabled: true
  data:
    DB_PASSWORD: stagingpassword456
apps:
  kotlin-spring:
    enabled: true
    image:
      tag: v1.0.0
    replicaCount: 2
```

## Namespace ConfigMap & Secrets

Each namespace creates a ConfigMap and Secret that are injected into all apps via `envFrom`:

```yaml
configMap:
  enabled: true
  data:
    APP_ENV: dev
    LOG_LEVEL: debug
    CORS_ALLOWED_ORIGINS: "http://localhost:3000"

secret:
  enabled: true
  data:
    DB_PASSWORD: changeme
    API_KEY: changeme
```

All apps in the namespace automatically receive these as environment variables.

## Adding a New Namespace

1. Create directory: `environments/<provider>/<namespace>/`
2. Copy an existing values.yaml as a template
3. Customize apps, tags, hosts, configMap, secrets
4. Deploy: `make namespace-deploy ENV=<provider> NS=<namespace>`

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

## GHCR Private Images

If your repos are private, create an image pull secret:

```bash
kubectl create secret docker-registry ghcr-pull \
  --docker-server=ghcr.io \
  --docker-username=thanhleothanh \
  --docker-password=<your-github-pat>
```

Then in the namespace values.yaml:

```yaml
imagePullSecrets:
  - name: ghcr-pull
```

## Prerequisites

- Helm 3.x
- `kubectl` configured for your cluster
- Access to your target cloud provider CLI (aws, az)
