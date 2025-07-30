#!/bin/bash
set -e

NAMESPACE="elastic-system"
AGENT_NAMESPACE="elastic-agent"
RELEASE_NAME="elastic-stack"
CHART_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Create namespaces if not exist
kubectl get namespace "$NAMESPACE" >/dev/null 2>&1 || kubectl create namespace "$NAMESPACE"
kubectl get namespace "$AGENT_NAMESPACE" >/dev/null 2>&1 || kubectl create namespace "$AGENT_NAMESPACE"

echo ">>> Deploying Elasticsearch & Kibana..."
helm upgrade --install "$RELEASE_NAME" "$CHART_PATH" -n "$NAMESPACE" --create-namespace

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

# Check if agent is enabled in values.yaml
AGENT_ENABLED=$(yq e '.agent.enabled // false' "$CHART_PATH/values.yaml" 2>/dev/null || echo "false")

if [[ "$AGENT_ENABLED" == "true" ]]; then
    echo ">>> Deploying Elastic Agent in namespace $AGENT_NAMESPACE..."
    helm upgrade --install elastic-agent "$CHART_PATH" -n "$AGENT_NAMESPACE" --set agent.enabled=true

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
else
    echo ">>> Elastic Agent deployment skipped (agent.enabled is false or not set)."
fi

echo ">>> Deployment complete."
