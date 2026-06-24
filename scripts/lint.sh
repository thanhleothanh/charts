#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
CLUSTER_CHART="$ROOT_DIR/charts/cluster"
NAMESPACE_CHART="$ROOT_DIR/charts/namespace"

echo "==> Linting cluster chart..."
helm lint "$CLUSTER_CHART"

echo "==> Linting namespace chart..."
helm lint "$NAMESPACE_CHART"

for env_dir in "$ROOT_DIR"/environments/*/; do
    env_name="$(basename "$env_dir")"
    echo "==> Linting $env_name cluster values..."
    helm lint "$CLUSTER_CHART" -f "$env_dir/cluster-values.yaml" 2>/dev/null || true

    for ns_dir in "$env_dir"/*/; do
        ns_name="$(basename "$ns_dir")"
        if [ -f "$ns_dir/values.yaml" ]; then
            echo "==> Linting $env_name/$ns_name namespace values..."
            helm lint "$NAMESPACE_CHART" -f "$ns_dir/values.yaml" 2>/dev/null || true
        fi
    done
done

echo "==> Lint complete!"
