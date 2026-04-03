#!/bin/bash
set -e

NAMESPACE="elastic-system"
RELEASE_NAME="elastic-operator"
OPERATOR_VERSION="3.3.2"

echo ">>> Installing ECK CRDs..."
kubectl apply -f https://download.elastic.co/downloads/eck/${OPERATOR_VERSION}/crds.yaml

helm repo add elastic https://helm.elastic.co
helm repo update

echo ">>> Installing Elastic ECK Operator Helm chart..."
helm upgrade --install $RELEASE_NAME elastic/eck-operator -n $NAMESPACE --create-namespace --set installCRDs=false

echo ">>> Waiting for ECK Operator StatefulSet rollout..."
kubectl rollout status statefulset/elastic-operator -n $NAMESPACE --timeout=180s

echo ">>> Elastic ECK Operator is ready."
