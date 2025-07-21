#!/bin/bash

# Base directory
BASE_DIR="./n8n"

# Create directories
mkdir -p ${BASE_DIR}/{templates,scripts,charts}

# Create Helm Chart metadata
cat > ${BASE_DIR}/Chart.yaml <<'EOF'
apiVersion: v2
name: n8n-stack
description: Helm chart for n8n Workflow Automation
type: application
version: 0.1.0
appVersion: "0.20.0"
EOF

# Create default values.yaml
cat > ${BASE_DIR}/values.yaml <<'EOF'
replicaCount: 1

image:
  repository: n8nio/n8n
  pullPolicy: IfNotPresent
  tag: "latest"

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: true
  className: nginx
  annotations: 
    kubernetes.io/ingress.class: nginx
  hosts:
    - host: n8n.local
      paths:
        - path: /
          pathType: Prefix
  tls: []
  # Example:
  # tls:
  #   - secretName: n8n-tls
  #     hosts:
  #       - n8n.local

persistence:
  enabled: true
  size: 1Gi
  accessModes:
    - ReadWriteOnce

config:
  database:
    type: sqlite

secret: {}

resources: {}
EOF

# Create placeholder templates
for tmpl in _helpers.tpl deployment.yaml service.yaml ingress.yaml pvc.yaml; do
    touch ${BASE_DIR}/templates/$tmpl
done

# Create deploy script
cat > ${BASE_DIR}/scripts/deploy.sh <<'EOF'
#!/bin/bash
set -e

NAMESPACE="n8n-system"
RELEASE_NAME="n8n-stack"
CHART_PATH=".."

echo ">>> Ensuring namespace $NAMESPACE exists"
kubectl get namespace "$NAMESPACE" >/dev/null 2>&1 || kubectl create namespace "$NAMESPACE"

echo ">>> Deploying n8n Helm chart..."
helm upgrade --install "$RELEASE_NAME" "$CHART_PATH" -n "$NAMESPACE"
EOF

chmod +x ${BASE_DIR}/scripts/deploy.sh

# Create uninstall script
cat > ${BASE_DIR}/scripts/uninstall.sh <<'EOF'
#!/bin/bash
set -e

NAMESPACE="n8n-system"

echo ">>> Uninstalling n8n-stack Helm release"
helm uninstall n8n-stack -n "$NAMESPACE" || true
EOF

chmod +x ${BASE_DIR}/scripts/uninstall.sh

echo "n8n Helm chart structure created at ${BASE_DIR}/"
