#!/bin/bash
set -e

NAMESPACE="elastic-system"
RELEASE_NAME="elastic-operator"
VERSION_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/version.env"

if [ -f "$VERSION_FILE" ]; then
    source "$VERSION_FILE"
else
    echo "ERROR: $VERSION_FILE not found."
    exit 1
fi

echo ">>> Installing ECK CRDs (Version: $ECK_OPERATOR_VERSION)..."
kubectl apply -f https://download.elastic.co/downloads/eck/${ECK_OPERATOR_VERSION}/crds.yaml

helm repo add elastic https://helm.elastic.co
helm repo update

echo ">>> Installing Elastic ECK Operator Helm chart (Version: $ECK_OPERATOR_VERSION)..."
helm upgrade --install $RELEASE_NAME elastic/eck-operator --version $ECK_OPERATOR_VERSION -n $NAMESPACE --create-namespace --set installCRDs=false

echo ">>> Waiting for ECK Operator StatefulSet rollout..."
kubectl rollout status statefulset/elastic-operator -n $NAMESPACE --timeout=180s

echo ">>> Elastic ECK Operator is ready."
