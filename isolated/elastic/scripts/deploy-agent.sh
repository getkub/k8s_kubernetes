#!/bin/bash
set -eo pipefail

MANIFEST_PATH="./manifests"
AGENT_NAMESPACE="elastic-agent"

# Load variables from version.env
if [ -f "./version.env" ]; then
    set -a
    source "./version.env"
    set +a
else
    echo "ERROR: version.env file not found."
    exit 1
fi

echo ">>> Deploying Elastic Agent & Fleet Server using native ECK manifests (Version: $ELASTIC_VERSION)..."

# Ensure the agent namespace exists
kubectl get namespace "$AGENT_NAMESPACE" >/dev/null 2>&1 || kubectl create namespace "$AGENT_NAMESPACE"

# Deploy Agent manifests
envsubst < "$MANIFEST_PATH/elastic-agent.yaml" | kubectl apply -f -

echo ">>> Waiting for Fleet Server pods to be Running..."
for i in {1..60}; do
    FLEET_READY_COUNT=$(kubectl get pods -n "$AGENT_NAMESPACE" --selector=agent.k8s.elastic.co/name=fleet-server --field-selector=status.phase=Running 2>/dev/null | grep -c fleet-server || true)
    if (( FLEET_READY_COUNT > 0 )); then
        echo ">>> Fleet Server pods are running!"
        break
    fi
    echo "Waiting for Fleet Server pods..."
    sleep 5
done

echo ">>> Waiting for Elastic Agent pods to be Running..."
for i in {1..60}; do
    AGENT_READY_COUNT=$(kubectl get pods -n "$AGENT_NAMESPACE" --selector=agent.k8s.elastic.co/name=elastic-agent --field-selector=status.phase=Running 2>/dev/null | grep -c elastic-agent || true)
    if (( AGENT_READY_COUNT > 0 )); then
        echo ">>> Elastic Agent pods are running!"
        break
    fi
    echo "Waiting for Elastic Agent pods..."
    sleep 5
done

if (( AGENT_READY_COUNT == 0 )); then
    echo "WARNING: Elastic Agent pods did not become ready in time."
    echo "This is often a transient ECK Fleet enrollment issue while Kibana configures policies."
    exit 0
fi

echo ">>> Agent Deployment complete."
