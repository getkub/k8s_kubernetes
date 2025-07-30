#!/bin/bash
set -e

NAMESPACE="elastic-system"
RELEASE_NAME="elastic-operator"

echo ">>> Installing ECK CRDs..."
kubectl apply -f https://download.elastic.co/downloads/eck/2.12.1/crds.yaml

helm repo add elastic https://helm.elastic.co
helm repo update

echo ">>> Installing Elastic ECK Operator Helm chart..."
helm upgrade --install $RELEASE_NAME elastic/eck-operator -n $NAMESPACE --create-namespace

echo ">>> Waiting for ECK Operator StatefulSet rollout..."
kubectl rollout status statefulset/elastic-operator -n $NAMESPACE --timeout=180s

echo ">>> Elastic ECK Operator is ready."
