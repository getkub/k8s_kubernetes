#!/bin/bash
set -e

NAMESPACE="elastic-system"
RELEASE_NAME="elastic-stack"
CHART_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo ">>> Deploying Elasticsearch & Kibana..."
helm upgrade --install $RELEASE_NAME $CHART_PATH -n $NAMESPACE --create-namespace

echo ">>> Waiting for Elasticsearch cluster to be Ready..."
for i in {1..60}; do
    PHASE=$(kubectl get elasticsearch -n $NAMESPACE -o jsonpath='{.items[0].status.phase}')
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

if kubectl get kibana -n $NAMESPACE >/dev/null 2>&1; then
    echo ">>> Waiting for Kibana CR to be Ready..."
    for i in {1..60}; do
        KIBANA_PHASE=$(kubectl get kibana -n $NAMESPACE -o jsonpath='{.items[0].status.health}' 2>/dev/null || echo "unknown")
        echo "Current Kibana health: $KIBANA_PHASE"
        if [[ "$KIBANA_PHASE" == "green" ]]; then
            echo ">>> Kibana is Ready!"
            break
        fi
        sleep 10
    done
fi

echo ">>> Elasticsearch & Kibana deployment complete."
