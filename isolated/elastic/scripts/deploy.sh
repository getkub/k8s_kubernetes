#!/bin/bash
set -e

NAMESPACE="elastic-system"
AGENT_NAMESPACE="elastic-agent"
MANIFEST_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/../manifests" && pwd)"
VERSION_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/version.env"

if [ -f "$VERSION_FILE" ]; then
    source "$VERSION_FILE"
    export ELASTIC_VERSION
else
    echo "ERROR: $VERSION_FILE not found."
    exit 1
fi

# Create namespaces if not exist
kubectl get namespace "$NAMESPACE" >/dev/null 2>&1 || kubectl create namespace "$NAMESPACE"
kubectl get namespace "$AGENT_NAMESPACE" >/dev/null 2>&1 || kubectl create namespace "$AGENT_NAMESPACE"

echo ">>> Deploying Elasticsearch & Kibana using native ECK manifests (Version: $ELASTIC_VERSION)..."
envsubst < "$MANIFEST_PATH/elasticsearch.yaml" | kubectl apply -f -
envsubst < "$MANIFEST_PATH/kibana.yaml" | kubectl apply -f -

echo ">>> Waiting for Elasticsearch cluster to be Ready..."
for i in {1..60}; do
    PHASE=$(kubectl get elasticsearch -n "$NAMESPACE" -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo "")
    echo "Current Elasticsearch phase: $PHASE"
    if [[ "$PHASE" == "Ready" ]]; then
        echo ">>> Elasticsearch is Ready!"
        break
    fi
    sleep 10
done

if [[ "$PHASE" != "Ready" ]]; then
    echo "ERROR: Elasticsearch did not become ready in time."
    exit 1
fi

echo ">>> Waiting for Kibana CR to be Ready..."
for i in {1..60}; do
    KIBANA_PHASE=$(kubectl get kibana -n "$NAMESPACE" -o jsonpath='{.items[0].status.health}' 2>/dev/null || echo "unknown")
    echo "Current Kibana health: $KIBANA_PHASE"
    if [[ "$KIBANA_PHASE" == "green" ]]; then
        echo ">>> Kibana is Ready!"
        break
    fi
    sleep 10
done

if [[ "$KIBANA_PHASE" != "green" ]]; then
    echo "ERROR: Kibana did not become ready in time."
    exit 1
fi

echo ">>> Deploying Elastic Agent in namespace $AGENT_NAMESPACE..."
envsubst < "$MANIFEST_PATH/elastic-agent.yaml" | kubectl apply -f -

echo ">>> Waiting for Elastic Agent pods to be Running..."
for i in {1..60}; do
    AGENT_READY_COUNT=$(kubectl get pods -n "$AGENT_NAMESPACE" --selector=agent.k8s.elastic.co/name=elastic-agent --field-selector=status.phase=Running 2>/dev/null | grep -c elastic-agent || echo 0)
    if (( AGENT_READY_COUNT > 0 )); then
        echo ">>> Elastic Agent pods are running!"
        break
    fi
    echo "Waiting for Elastic Agent pods..."
    sleep 5
done

if (( AGENT_READY_COUNT == 0 )); then
    echo "ERROR: Elastic Agent pods did not become ready in time."
    exit 1
fi

echo ">>> Deployment complete."
