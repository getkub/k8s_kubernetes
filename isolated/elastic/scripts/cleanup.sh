#!/bin/bash
set -e

ELASTIC_NAMESPACE="elastic-system"
AGENT_NAMESPACE="elastic-agent"

echo ">>> Uninstalling Helm releases (if any)..."
if helm list -n "$ELASTIC_NAMESPACE" 2>/dev/null | grep -q elastic-stack; then
  echo "  Removing elastic-stack release..."
  helm uninstall elastic-stack -n "$ELASTIC_NAMESPACE" || true
else
  echo "  elastic-stack release not found, skipping."
fi

if helm list -n "$ELASTIC_NAMESPACE" 2>/dev/null | grep -q elastic-operator; then
  echo "  Removing elastic-operator release..."
  helm uninstall elastic-operator -n "$ELASTIC_NAMESPACE" || true
else
  echo "  elastic-operator release not found, skipping."
fi

echo ">>> Deleting cluster roles and role bindings..."
for cr in elastic-operator-edit elastic-operator-view elastic-operator; do
  if kubectl get clusterrole "$cr" >/dev/null 2>&1; then
    echo "  Deleting clusterrole $cr..."
    kubectl delete clusterrole "$cr" || true
  else
    echo "  clusterrole $cr not found, skipping."
  fi
done

for crb in elastic-operator elastic-operator-view; do
  if kubectl get clusterrolebinding "$crb" >/dev/null 2>&1; then
    echo "  Deleting clusterrolebinding $crb..."
    kubectl delete clusterrolebinding "$crb" || true
  else
    echo "  clusterrolebinding $crb not found, skipping."
  fi
done

echo ">>> Deleting namespaces if they exist..."
if kubectl get namespace "$AGENT_NAMESPACE" >/dev/null 2>&1; then
  echo "  Deleting namespace $AGENT_NAMESPACE..."
  kubectl delete namespace "$AGENT_NAMESPACE" || true
else
  echo "  Namespace $AGENT_NAMESPACE not found, skipping."
fi

if kubectl get namespace "$ELASTIC_NAMESPACE" >/dev/null 2>&1; then
  echo "  Deleting namespace $ELASTIC_NAMESPACE..."
  kubectl delete namespace "$ELASTIC_NAMESPACE" || true
else
  echo "  Namespace $ELASTIC_NAMESPACE not found, skipping."
fi

echo ">>> Deleting Elastic CRDs..."
ELASTIC_CRDS=$(kubectl get crds 2>/dev/null | grep elastic | awk '{print $1}')
if [ -n "$ELASTIC_CRDS" ]; then
  echo "  Found Elastic CRDs:"
  echo "$ELASTIC_CRDS" | while read crd; do
    echo "    - $crd"
  done
  echo "$ELASTIC_CRDS" | xargs -r kubectl delete crd || true
else
  echo "  No Elastic CRDs found, skipping."
fi

echo ">>> Waiting for CRDs to be fully deleted..."
for i in {1..30}; do
  CRDS=$(kubectl get crds 2>/dev/null | grep elastic | wc -l)
  if [ "$CRDS" -eq 0 ]; then
    echo "All Elastic CRDs deleted."
    break
  fi
  echo "Waiting for $CRDS Elastic CRDs to be deleted... (attempt $i/30)"
  sleep 2
done

echo ">>> Cleanup complete."
