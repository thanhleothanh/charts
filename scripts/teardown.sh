#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

ENV="${1:-self-hosted}"
NS="${2:-dev}"

echo "==> Tearing down namespace: $NS"
helm uninstall "$NS"-apps -n "$NS" 2>/dev/null || echo "No namespace release found."

read -p "Tear down cluster infra too? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "==> Tearing down cluster infra..."
    helm uninstall personal-cluster 2>/dev/null || echo "No cluster release found."
fi

echo "==> Teardown complete!"
