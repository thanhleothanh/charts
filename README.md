# Personal Kubernetes Cluster

Helm-based project for managing a personal Kubernetes cluster with namespace-based environment separation.

All images are pulled from `ghcr.io/thanhleothanh/<project>:latest`.

## Architecture

```
charts/
├── cluster/              # Shared infra (ingress-controller) — deployed ONCE per cluster
├── ingress-controller/   # Traefik ingress controller
├── namespace/            # Apps — deployed PER namespace (dev, staging, ...)
└── monitoring/           # Prometheus + Grafana (placeholder)

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

## Current Setup

| Component | Details |
|-----------|---------|
| Cluster | k3s v1.35.5+k3s1 on Rancher Desktop |
| Ingress | Traefik v3.0, NodePort 30080 (HTTP) / 30443 (HTTPS) |

## Prerequisites

- k3s (via Rancher Desktop or Docker Desktop)
- Helm 3.x
- `kubectl` configured for your cluster
- PostgreSQL running in Docker (for kotlin-spring)

## Step-by-Step: Bring Up the Application

### 1. Verify k3s is running

```bash
kubectl get nodes
```

You should see a node with status `Ready`.

### 2. Deploy cluster infrastructure (Traefik)

```bash
helm upgrade --install personal-cluster charts/cluster \
  -n default \
  -f environments/self-hosted/cluster-values.yaml \
  --wait
```

Verify Traefik is running:

```bash
kubectl get svc personal-cluster-ingress-controller
```

You should see NodePorts `30080/TCP` and `30443/TCP`.

### 3. Deploy apps to dev namespace

```bash
helm upgrade --install dev-apps charts/namespace \
  -n dev --create-namespace \
  -f environments/self-hosted/dev/values.yaml \
  --wait
```

Verify the app is running:

```bash
kubectl get pods -n dev
kubectl get svc -n dev
```

## Teardown

```bash
# Remove apps
helm uninstall dev-apps -n dev
kubectl delete namespace dev

# Remove cluster infra
helm uninstall personal-cluster -n default
```

## Per-Namespace Configuration

Each namespace gets its own `values.yaml` with:

- **Which apps** are enabled/disabled
- **Image tags** (e.g., `latest` for dev, `v1.0.0` for staging)
- **Resource quotas** per namespace
- **Ingress hosts** (e.g., `app.dev.example.com` vs `app.staging.example.com`)
- **ConfigMap** — shared non-sensitive env vars for all apps
- **Secret** — shared sensitive env vars for all apps

## Adding a New Namespace

1. Create directory: `environments/self-hosted/<namespace>/`
2. Copy an existing values.yaml as a template
3. Customize apps, tags, hosts, configMap, secrets
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
