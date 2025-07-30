#!/bin/bash
set -e

ELASTIC_NAMESPACE="elastic-system"
AGENT_NAMESPACE="elastic-agent"

echo ">>> Uninstalling Helm releases (if any)..."
helm uninstall elastic-stack -n "$ELASTIC_NAMESPACE" || true
helm uninstall elastic-operator -n "$ELASTIC_NAMESPACE" || true

echo ">>> Deleting cluster roles and role bindings..."
kubectl delete clusterrole elastic-operator-edit elastic-operator-view elastic-operator || true
kubectl delete clusterrolebinding elastic-operator elastic-operator-view || true

echo ">>> Deleting namespaces if they exist..."

kubectl get namespace "$AGENT_NAMESPACE" >/dev/null 2>&1 && {
  echo "Deleting namespace $AGENT_NAMESPACE..."
  kubectl delete namespace "$AGENT_NAMESPACE" || true
}

kubectl get namespace "$ELASTIC_NAMESPACE" >/dev/null 2>&1 && {
  echo "Deleting namespace $ELASTIC_NAMESPACE..."
  kubectl delete namespace "$ELASTIC_NAMESPACE" || true
}

echo ">>> Deleting Elastic CRDs..."
kubectl get crds | grep elastic | awk '{print $1}' | xargs -r kubectl delete crd || true

echo ">>> Cleanup complete."
