#!/bin/bash
set -e

ELASTIC_NAMESPACE="elastic-system"
AGENT_NAMESPACE="elastic-agent"
RELEASE_NAME="elastic-stack"
OPERATOR_RELEASE_NAME="elastic-operator"

echo ">>> Uninstalling Helm release $RELEASE_NAME from namespace $ELASTIC_NAMESPACE..."
helm uninstall "$RELEASE_NAME" -n "$ELASTIC_NAMESPACE" || true

echo ">>> Uninstalling Helm release $OPERATOR_RELEASE_NAME from namespace $ELASTIC_NAMESPACE..."
helm uninstall "$OPERATOR_RELEASE_NAME" -n "$ELASTIC_NAMESPACE" || true

echo ">>> Deleting namespaces if they exist..."

kubectl get namespace "$AGENT_NAMESPACE" >/dev/null 2>&1 && {
  echo "Deleting namespace $AGENT_NAMESPACE..."
  kubectl delete namespace "$AGENT_NAMESPACE" || true
}

kubectl get namespace "$ELASTIC_NAMESPACE" >/dev/null 2>&1 && {
  echo "Deleting namespace $ELASTIC_NAMESPACE..."
  kubectl delete namespace "$ELASTIC_NAMESPACE" || true
}

echo ">>> Uninstall complete."
