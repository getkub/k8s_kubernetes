#!/bin/bash
set -e

NAMESPACE="elastic-system"

echo ">>> Uninstalling elastic-stack Helm release"
helm uninstall elastic-stack -n "$NAMESPACE" || true

echo ">>> Uninstalling elastic-operator Helm release"
helm uninstall elastic-operator -n "$NAMESPACE" || true

echo ">>> Optionally delete namespace $NAMESPACE"
kubectl delete namespace "$NAMESPACE" || true
