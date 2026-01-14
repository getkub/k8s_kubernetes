#!/bin/bash

set -e

CA_DIR="../ca"
SERVER_DIR="../server"
K8S_SECRET_TEMPLATE="../k8s-tls-secret.yaml"
K8S_SECRET_OUTPUT="../k8s-tls-secret-populated.yaml"

CA_CERT="$CA_DIR/ca.crt"
SERVER_CERT="$SERVER_DIR/server.crt"
SERVER_KEY="$SERVER_DIR/server.key"

# Check if certificates exist
if [ ! -f "$CA_CERT" ] || [ ! -f "$SERVER_CERT" ] || [ ! -f "$SERVER_KEY" ]; then
    echo "Error: Certificates not found. Please run generate-ca.sh and generate-server-cert.sh first."
    exit 1
fi

echo "Generating Kubernetes TLS secret..."

# Base64 encode the certificates
CA_CERT_B64=$(base64 -w 0 < "$CA_CERT")
SERVER_CERT_B64=$(base64 -w 0 < "$SERVER_CERT")
SERVER_KEY_B64=$(base64 -w 0 < "$SERVER_KEY")

# Create the populated secret
cat > "$K8S_SECRET_OUTPUT" << EOF
apiVersion: v1
kind: Secret
metadata:
  name: local-dev-tls
  namespace: n8n-system
type: kubernetes.io/tls
data:
  tls.crt: $SERVER_CERT_B64
  tls.key: $SERVER_KEY_B64
  ca.crt: $CA_CERT_B64
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-dev-ca
  namespace: n8n-system
data:
  ca.crt: $CA_CERT_B64
EOF

echo "Kubernetes TLS secret generated: $K8S_SECRET_OUTPUT"
echo ""
echo "To apply to Kubernetes:"
echo "kubectl apply -f $K8S_SECRET_OUTPUT"
echo ""
echo "To use in n8n Helm chart, update values.yaml with:"
echo "tls:"
echo "  enabled: true"
echo "  secretName: local-dev-tls"
