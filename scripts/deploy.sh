#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

ENV="${1:-self-hosted}"
NS="${2:-dev}"
CLUSTER_CHART="$ROOT_DIR/charts/cluster"
NAMESPACE_CHART="$ROOT_DIR/charts/namespace"

echo "==> Deploying cluster infra to $ENV..."
helm dependency build "$CLUSTER_CHART" 2>/dev/null || true
helm upgrade --install personal-cluster "$CLUSTER_CHART" \
    -f "$ROOT_DIR/environments/$ENV/cluster-values.yaml" \
    --wait --timeout 5m

echo "==> Creating namespace $NS..."
kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -

echo "==> Deploying apps to namespace $NS..."
helm upgrade --install "$NS"-apps "$NAMESPACE_CHART" \
    -n "$NS" \
    -f "$ROOT_DIR/environments/$ENV/$NS/values.yaml" \
    --wait --timeout 5m

echo "==> Deploy complete! (cluster + $NS namespace)"
