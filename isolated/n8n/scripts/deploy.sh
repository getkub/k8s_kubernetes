#!/bin/bash
set -e

NAMESPACE="n8n-system"
RELEASE_NAME="n8n-stack"
CHART_PATH=".."

echo ">>> Ensuring namespace $NAMESPACE exists"
kubectl get namespace "$NAMESPACE" >/dev/null 2>&1 || kubectl create namespace "$NAMESPACE"

echo ">>> Deploying n8n Helm chart..."
helm upgrade --install "$RELEASE_NAME" "$CHART_PATH" -n "$NAMESPACE"
