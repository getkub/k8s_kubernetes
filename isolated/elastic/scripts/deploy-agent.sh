#!/bin/bash
set -eo pipefail

MANIFEST_PATH="./manifests"
AGENT_NAMESPACE="elastic-agent"
ES_SECRET_NAME="quickstart-es-elastic-user"
ES_SECRET_NS="elastic-system"
ENDPOINT_NAMESPACE="endpoint-simulation"
ENDPOINT_DEPLOYMENT="linux-endpoints"

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

echo "🔐 Extracting 'elastic' password from Elasticsearch secret..."
for i in {1..60}; do
  if kubectl get secret "$ES_SECRET_NAME" -n "$ES_SECRET_NS" >/dev/null 2>&1; then
    PASSWORD=$(kubectl get secret "$ES_SECRET_NAME" -n "$ES_SECRET_NS" -o jsonpath="{.data.elastic}" | base64 --decode)
    break
  fi
  sleep 1
done

if [ -z "${PASSWORD:-}" ]; then
  echo "❌ ERROR: Failed to get Elasticsearch password. Make sure Elasticsearch is deployed first."
  exit 1
fi

echo "📡 Starting port-forward to Kibana to configure Fleet policies..."
kubectl port-forward -n "$ES_SECRET_NS" svc/kibana-kb-http 5601:5601 >/dev/null 2>&1 &
PF_PID=$!
trap 'if ps -p $PF_PID > /dev/null; then kill $PF_PID; fi' EXIT

echo "⏳ Waiting for Kibana API to become ready..."
for i in {1..60}; do
  if curl -sk -I "https://localhost:5601/api/status" | grep -E "200 OK|HTTP/2 200"; then
    echo "✅ Kibana API is ready."
    break
  fi
  sleep 2
done

echo "⚙️ Initializing Fleet setup..."
curl -sk -u elastic:"$PASSWORD" -X POST "https://localhost:5601/api/fleet/setup" -H 'kbn-xsrf: true' > /dev/null

echo "⚙️ Checking for existing policies..."
# Function to check if a policy exists (returns 0 if exists, 1 if not)
policy_exists() {
  local status_code
  status_code=$(curl -sk -u elastic:"$PASSWORD" -X GET "https://localhost:5601/api/fleet/agent_policies/$1" -o /dev/null -w "%{http_code}")
  [ "$status_code" -eq 200 ]
}

echo "⚙️ Configuring Fleet Server host in settings..."
# First check if it already exists to avoid duplicates
EXISTING_HOSTS=$(curl -sk -u elastic:"$PASSWORD" -X GET "https://localhost:5601/api/fleet/fleet_server_hosts" | jq -r '.items[]? | .host_urls[]?')
if ! echo "$EXISTING_HOSTS" | grep -q "https://fleet-server-agent-http.elastic-agent.svc.cluster.local:8220"; then
    curl -sk -u elastic:"$PASSWORD" -X POST "https://localhost:5601/api/fleet/fleet_server_hosts" \
      -H 'kbn-xsrf: true' -H 'Content-Type: application/json' \
      -d "{
        \"name\": \"Internal Fleet Server\",
        \"host_urls\": [\"https://fleet-server-agent-http.elastic-agent.svc.cluster.local:8220\"],
        \"is_default\": true
      }" > /dev/null
else
    echo "✅ Fleet Server host already configured in settings."
fi

echo "⚙️ Configuring Fleet output to point to internal Elasticsearch service..."
curl -sk -u elastic:"$PASSWORD" -X PUT "https://localhost:5601/api/fleet/outputs/fleet-default-output" \
  -H 'kbn-xsrf: true' -H 'Content-Type: application/json' \
  -d "{
    \"name\": \"default\",
    \"hosts\": [\"https://quickstart-es-http.elastic-system.svc:9200\"],
    \"is_default\": true,
    \"is_default_monitoring\": true,
    \"type\": \"elasticsearch\",
    \"ssl\": {
      \"verification_mode\": \"none\"
    }
  }" > /dev/null

if ! policy_exists "eck-fleet-server"; then
    echo "⚙️ Creating eck-fleet-server policy..."
    curl -sk -u elastic:"$PASSWORD" -X POST "https://localhost:5601/api/fleet/agent_policies" \
      -H 'kbn-xsrf: true' -H 'Content-Type: application/json' \
      -d "{
        \"id\": \"eck-fleet-server\",
        \"name\": \"eck-fleet-server\",
        \"namespace\": \"default\",
        \"monitoring_enabled\": [\"logs\", \"metrics\"],
        \"has_fleet_server\": true
      }" > /dev/null
else
    echo "✅ eck-fleet-server policy already exists."
fi

if ! policy_exists "eck-agent"; then
    echo "⚙️ Creating eck-agent policy..."
    curl -sk -u elastic:"$PASSWORD" -X POST "https://localhost:5601/api/fleet/agent_policies" \
      -H 'kbn-xsrf: true' -H 'Content-Type: application/json' \
      -d "{\"id\":\"eck-agent\",\"name\":\"eck-agent\",\"namespace\":\"default\",\"monitoring_enabled\":[\"logs\",\"metrics\"]}" > /dev/null
else
    echo "✅ eck-agent policy already exists."
fi

if ! policy_exists "linux-endpoints-policy"; then
    echo "⚙️ Creating linux-endpoints-policy..."
    curl -sk -u elastic:"$PASSWORD" -X POST "https://localhost:5601/api/fleet/agent_policies" \
      -H 'kbn-xsrf: true' -H 'Content-Type: application/json' \
      -d "{\"id\":\"linux-endpoints-policy\",\"name\":\"linux-endpoints-policy\",\"namespace\":\"default\",\"monitoring_enabled\":[\"logs\",\"metrics\"]}" > /dev/null
else
    echo "✅ linux-endpoints-policy already exists."
fi

# Get the policy ID for linux-endpoints-policy
echo "🎫 Fetching linux-endpoints-policy ID..."
POLICY_ID=$(curl -sk -u elastic:"$PASSWORD" -X GET "https://localhost:5601/api/fleet/agent_policies" | jq -r '.items[] | select(.name=="linux-endpoints-policy") | .id')

if [ -n "$POLICY_ID" ] && [ "$POLICY_ID" != "null" ]; then
    echo "🎫 Checking for existing enrollment token for linux-endpoints-policy..."
    # Try to find an existing token first
    ENROLLMENT_TOKEN=$(curl -sk -u elastic:"$PASSWORD" -X GET "https://localhost:5601/api/fleet/enrollment_api_keys" | jq -r ".items[] | select(.policy_id==\"$POLICY_ID\") | .api_key" | head -n 1)
    
    if [ -z "$ENROLLMENT_TOKEN" ] || [ "$ENROLLMENT_TOKEN" == "null" ]; then
        echo "🎫 Requesting new enrollment token..."
        ENROLLMENT_TOKEN=$(curl -sk -u elastic:"$PASSWORD" -X POST "https://localhost:5601/api/fleet/enrollment_api_keys" \
          -H 'kbn-xsrf: true' -H 'Content-Type: application/json' \
          -d "{\"policy_id\":\"$POLICY_ID\"}" | jq -r '.item.api_key')
    fi
    
    if [ -n "$ENROLLMENT_TOKEN" ] && [ "$ENROLLMENT_TOKEN" != "null" ]; then
        echo "✅ Enrollment token retrieved."
    else
        echo "❌ ERROR: Failed to get enrollment token."
        exit 1
    fi
else
    echo "⚠️ WARNING: Failed to get policy ID for linux-endpoints-policy."
fi

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

if [ -n "${ENROLLMENT_TOKEN:-}" ]; then
    FLEET_URL="https://fleet-server-agent-http.elastic-agent.svc.cluster.local:8220"
    
    # Only patch if necessary to avoid unnecessary rollouts
    CURRENT_FLEET_URL=$(kubectl get deployment "$ENDPOINT_DEPLOYMENT" -n "$ENDPOINT_NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="FLEET_URL")].value}' 2>/dev/null || echo "")
    CURRENT_TOKEN=$(kubectl get deployment "$ENDPOINT_DEPLOYMENT" -n "$ENDPOINT_NAMESPACE" -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="ENROLLMENT_TOKEN")].value}' 2>/dev/null || echo "")
    
    if [ "$CURRENT_FLEET_URL" != "$FLEET_URL" ] || [ "$CURRENT_TOKEN" != "$ENROLLMENT_TOKEN" ]; then
        echo "🔗 Linking linux endpoints to new Fleet Server at $FLEET_URL..."
        if kubectl get deployment "$ENDPOINT_DEPLOYMENT" -n "$ENDPOINT_NAMESPACE" >/dev/null 2>&1; then
            kubectl set env deployment/"$ENDPOINT_DEPLOYMENT" -n "$ENDPOINT_NAMESPACE" \
                FLEET_URL="$FLEET_URL" \
                ENROLLMENT_TOKEN="$ENROLLMENT_TOKEN"
            echo "✅ linux-endpoints deployment updated."
        fi
    else
        echo "✅ linux-endpoints deployment already has correct Fleet configuration. Skipping patch."
    fi
fi

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

echo ">>> Agent Deployment & Endpoint Linking complete."
