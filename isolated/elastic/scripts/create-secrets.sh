#!/bin/bash
set -euo pipefail

ES_SECRET_NAME="quickstart-es-elastic-user"
ES_SECRET_NS="elastic-system"
#AGENT_SECRET_NAME="elastic-agent-enrollment-token"
#AGENT_SECRET_NS="elastic-agent"
TMPFILE=$(mktemp)

echo "🔐 Extracting 'elastic' password from Elasticsearch secret..."
PASSWORD=$(kubectl get secret quickstart-es-elastic-user -n "$ES_SECRET_NS" -o jsonpath="{.data.elastic}" | base64 --decode)

echo "🔐 Creating Kubernetes secret for Elastic password..."
kubectl delete secret "$ES_SECRET_NAME" -n "$ES_SECRET_NS" --ignore-not-found
kubectl create secret generic "$ES_SECRET_NAME" -n "$ES_SECRET_NS" --from-literal=elastic="$PASSWORD"

echo "📡 Starting port-forward to Kibana..."
kubectl port-forward -n "$ES_SECRET_NS" svc/kibana-kb-http 5601:5601 >/dev/null 2>&1 &
PF_PID=$!
trap 'if ps -p $PF_PID > /dev/null; then kill $PF_PID; fi' EXIT

sleep 2  # Give port-forward a moment to establish

KIBANA_HOST="https://localhost:5601"

wait_for_kibana() {
  echo "⏳ Waiting for Kibana to become ready at $KIBANA_HOST..."
  until curl -sk --max-time 3 "$KIBANA_HOST/api/status" -o "$TMPFILE" && grep -q '"level":"available"' "$TMPFILE"; do
    sleep 5
  done
  echo "✅ Kibana is ready."
}

wait_for_kibana

# Enrollment token creation disabled for now
#: '
#echo "🔎 Checking if Fleet policy 'k8s-policy' exists..."
#
#POLICY_ID=$(curl -sk -u elastic:"$PASSWORD" "$KIBANA_HOST/api/fleet/agent_policies" \
#  -H 'kbn-xsrf: true' | jq -r --arg NAME "k8s-policy" '.items[] | select(.name == $NAME) | .id' | head -n1)
#
#if [[ -z "$POLICY_ID" ]]; then
#  echo "📋 Fleet policy 'k8s-policy' not found. Creating it now..."
#
#  CREATE_RESPONSE=$(curl -sk -u elastic:"$PASSWORD" -X POST "$KIBANA_HOST/api/fleet/agent_policies" \
#    -H 'kbn-xsrf: true' -H 'Content-Type: application/json' \
#    -d "{\"name\":\"k8s-policy\",\"namespace\":\"default\",\"monitoring_enabled\":[\"logs\",\"metrics\"]}")
#
#  POLICY_ID=$(echo "$CREATE_RESPONSE" | jq -r '.id // empty')
#  ERROR_MESSAGE=$(echo "$CREATE_RESPONSE" | jq -r '.message // empty')
#
#  if [[ -n "$ERROR_MESSAGE" && "$ERROR_MESSAGE" == *"already exists"* ]]; then
#    echo "⚠️ Policy already exists according to API error message, fetching ID again..."
#    POLICY_ID=$(curl -sk -u elastic:"$PASSWORD" "$KIBANA_HOST/api/fleet/agent_policies" \
#      -H 'kbn-xsrf: true' | jq -r --arg NAME "k8s-policy" '.items[] | select(.name == $NAME) | .id' | head -n1)
#  fi
#
#  if [[ -z "$POLICY_ID" ]]; then
#    echo "❌ ERROR: Failed to create or locate Fleet policy 'k8s-policy'."
#    exit 1
#  fi
#
#  echo "✅ Fleet policy 'k8s-policy' ready with ID: $POLICY_ID"
#else
#  echo "✅ Fleet policy 'k8s-policy' exists with ID: $POLICY_ID"
#fi
#
#echo "🎫 Requesting enrollment token for policy ID: $POLICY_ID..."
#
#ENROLLMENT_TOKEN=$(curl -sk -u elastic:"$PASSWORD" -X POST "$KIBANA_HOST/api/fleet/enrollment_api_keys" \
#  -H 'kbn-xsrf: true' -H 'Content-Type: application/json' \
#  -d "{\"policy_id\":\"$POLICY_ID\"}" | jq -r '.item.api_key')
#
#if [[ -z "$ENROLLMENT_TOKEN" || "$ENROLLMENT_TOKEN" == "null" ]]; then
#  echo "❌ ERROR: Failed to get enrollment token."
#  exit 1
#fi
#
#echo "🎫 Creating Kubernetes secret for Fleet enrollment token..."
#kubectl delete secret "$AGENT_SECRET_NAME" -n "$AGENT_SECRET_NS" --ignore-not-found
#kubectl create secret generic "$AGENT_SECRET_NAME" -n "$AGENT_SECRET_NS" --from-literal=token="$ENROLLMENT_TOKEN"
#
#echo "✅ Secrets created successfully:"
#echo "   - Elastic password → secret/$ES_SECRET_NAME (ns: $ES_SECRET_NS)"
#echo "   - Enrollment token → secret/$AGENT_SECRET_NAME (ns: $AGENT_SECRET_NS)"
#'

echo "✅ Secret for Elastic password created successfully:"
echo "   - Elastic password → secret/$ES_SECRET_NAME (ns: $ES_SECRET_NS)"
