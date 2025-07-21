#!/bin/bash
set -e

NAMESPACE="n8n-system"

echo ">>> Cleaning up PVCs for n8n..."
kubectl delete pvc -n "$NAMESPACE" --all || true
