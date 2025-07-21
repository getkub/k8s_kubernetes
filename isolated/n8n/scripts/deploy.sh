#!/bin/bash
set -e

NAMESPACE="n8n-system"
RELEASE_NAME="n8n-stack"
CHART_PATH="."

echo ">>> Ensuring namespace $NAMESPACE exists..."
kubectl get namespace "$NAMESPACE" >/dev/null 2>&1 || kubectl create namespace "$NAMESPACE"

echo ">>> Deploying n8n Helm chart..."
helm upgrade --install "$RELEASE_NAME" "$CHART_PATH" -n "$NAMESPACE"

echo ">>> Waiting for n8n pod(s) to be ready..."

# Get deployment name(s) with label app.kubernetes.io/instance=$RELEASE_NAME
DEPLOYMENTS=$(kubectl get deployments -n "$NAMESPACE" -l "app.kubernetes.io/instance=$RELEASE_NAME" -o jsonpath='{.items[*].metadata.name}')

if [ -z "$DEPLOYMENTS" ]; then
  echo "No deployments found for release $RELEASE_NAME in namespace $NAMESPACE"
else
  for deploy in $DEPLOYMENTS; do
    echo "Waiting for deployment/$deploy rollout..."
    kubectl rollout status deployment/$deploy -n "$NAMESPACE" --timeout=180s
  done
fi

# Check service
SERVICE_NAME=$(kubectl get svc -n "$NAMESPACE" -o jsonpath="{.items[0].metadata.name}")
SERVICE_PORT=$(kubectl get svc "$SERVICE_NAME" -n "$NAMESPACE" -o jsonpath="{.spec.ports[0].port}")

echo ">>> Service detected: $SERVICE_NAME on port $SERVICE_PORT"

# Check ingress
INGRESS_ENABLED=$(helm get values "$RELEASE_NAME" -n "$NAMESPACE" -o yaml | grep 'enabled:' | grep ingress | awk '{print $2}')
if [[ "$INGRESS_ENABLED" == "true" ]]; then
    echo ">>> Ingress is enabled. Access n8n at:"
    kubectl get ingress -n "$NAMESPACE"
else
    echo ">>> Ingress not enabled. Port-forward with:"
    echo "kubectl port-forward svc/$SERVICE_NAME 5678:80 -n $NAMESPACE"
    echo "Then open http://localhost:5678"
fi
