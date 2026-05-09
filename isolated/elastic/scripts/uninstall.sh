#!/bin/bash
set -e

ELASTIC_NAMESPACE="elastic-system"
AGENT_NAMESPACE="elastic-agent"
OPERATOR_RELEASE_NAME="elastic-operator"
MANIFEST_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/../manifests" && pwd)"
VERSION_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/version.env"

if [ -f "$VERSION_FILE" ]; then
    source "$VERSION_FILE"
    export ELASTIC_VERSION
else
    # Fallback if somehow version.env is missing
    export ELASTIC_VERSION="9.4.0"
fi

echo ">>> Uninstalling Elastic resources from namespace $ELASTIC_NAMESPACE and $AGENT_NAMESPACE..."
envsubst < "$MANIFEST_PATH/elastic-agent.yaml" | kubectl delete -f - || true
envsubst < "$MANIFEST_PATH/kibana.yaml" | kubectl delete -f - || true
envsubst < "$MANIFEST_PATH/elasticsearch.yaml" | kubectl delete -f - || true

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
