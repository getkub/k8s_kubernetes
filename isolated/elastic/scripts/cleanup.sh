#!/bin/bash
set -e

NAMESPACE="elastic-system"

echo ">>> Uninstalling Helm releases (if any)..."
helm uninstall elastic-stack -n "$NAMESPACE" || true
helm uninstall elastic-operator -n "$NAMESPACE" || true

echo ">>> Deleting cluster roles and role bindings..."
kubectl delete clusterrole elastic-operator-edit elastic-operator-view elastic-operator || true
kubectl delete clusterrolebinding elastic-operator elastic-operator-view || true

echo ">>> Deleting namespace $NAMESPACE..."
kubectl delete namespace "$NAMESPACE" || true

echo ">>> Deleting Elastic CRDs..."
kubectl get crds | grep elastic | awk '{print $1}' | xargs -r kubectl delete crd

echo ">>> Cleanup complete."
