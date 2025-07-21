#!/bin/bash

# Base directory
BASE_DIR="./elastic"

# Create directories
mkdir -p ${BASE_DIR}/{templates,charts,files/{certs,dashboards},scripts}

# Create core Helm files
cat > ${BASE_DIR}/Chart.yaml <<'EOF'
apiVersion: v2
name: elastic-stack
description: Helm chart for Elasticsearch, Kibana, and Beats custom resources
type: application
version: 0.1.0
appVersion: "9.0.3"
EOF

cat > ${BASE_DIR}/values.yaml <<'EOF'
elasticsearch:
  name: quickstart
  version: 9.0.3
  replicas: 3
  storageSize: 20Gi

kibana:
  enabled: true
  replicas: 1

beats:
  enabled: false

ingress:
  enabled: false
EOF

# Create placeholder template files
for tmpl in _helpers.tpl elasticsearch.yaml kibana.yaml beats.yaml ingress.yaml; do
    touch ${BASE_DIR}/templates/$tmpl
done

# Create deploy script to install ES/Kibana CRs only
cat > ${BASE_DIR}/scripts/deploy.sh <<'EOF'
#!/bin/bash
set -e

NAMESPACE="elastic-system"
RELEASE_NAME="elastic-stack"
CHART_PATH=".."

echo ">>> Ensuring namespace $NAMESPACE exists"
kubectl get namespace "$NAMESPACE" >/dev/null 2>&1 || kubectl create namespace "$NAMESPACE"

echo ">>> Deploying Elasticsearch, Kibana, Beats CRs via Helm chart $RELEASE_NAME"
helm upgrade --install "$RELEASE_NAME" "$CHART_PATH" -n "$NAMESPACE"
EOF

chmod +x ${BASE_DIR}/scripts/deploy.sh

# Create deploy-operator.sh to install official ECK operator
cat > ${BASE_DIR}/scripts/deploy-operator.sh <<'EOF'
#!/bin/bash
set -e

NAMESPACE="elastic-system"
RELEASE_NAME="elastic-operator"

helm repo add elastic https://helm.elastic.co
helm repo update

echo ">>> Installing Elastic ECK Operator Helm chart..."
helm upgrade --install $RELEASE_NAME elastic/eck-operator -n $NAMESPACE --create-namespace

echo ">>> Waiting for operator rollout..."
kubectl rollout status deployment/elastic-operator -n $NAMESPACE --timeout=180s
EOF

chmod +x ${BASE_DIR}/scripts/deploy-operator.sh

# Create uninstall script
cat > ${BASE_DIR}/scripts/uninstall.sh <<'EOF'
#!/bin/bash
set -e

NAMESPACE="elastic-system"

echo ">>> Uninstalling elastic-stack Helm release"
helm uninstall elastic-stack -n "$NAMESPACE" || true

echo ">>> Uninstalling elastic-operator Helm release"
helm uninstall elastic-ope
