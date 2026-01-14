#!/bin/bash

set -e

CA_DIR="../ca"
CA_CERT="$CA_DIR/ca.crt"
NODE_EXTRA_CA_CERTS="${NODE_EXTRA_CA_CERTS:-$HOME/.node/extra-ca-certs.crt}"

echo "Adding CA certificate to Node.js trust store..."

# Check if CA certificate exists
if [ ! -f "$CA_CERT" ]; then
    echo "Error: CA certificate not found at $CA_CERT"
    echo "Please run generate-ca.sh first."
    exit 1
fi

# Create directory if it doesn't exist
mkdir -p "$(dirname "$NODE_EXTRA_CA_CERTS")"

# Check if the certificate is already in the trust store
if [ -f "$NODE_EXTRA_CA_CERTS" ]; then
    if openssl x509 -in "$CA_CERT" -noout -fingerprint | grep -q "$(openssl x509 -in "$NODE_EXTRA_CA_CERTS" -noout -fingerprint 2>/dev/null)"; then
        echo "CA certificate is already in Node.js trust store."
        exit 0
    fi
fi

# Append CA certificate to the trust store
cat "$CA_CERT" >> "$NODE_EXTRA_CA_CERTS"

echo "CA certificate added to Node.js trust store: $NODE_EXTRA_CA_CERTS"
echo ""
echo "To use this trust store with Node.js applications, set the environment variable:"
echo "export NODE_EXTRA_CA_CERTS=\"$NODE_EXTRA_CA_CERTS\""
echo ""
echo "Or run your Node.js application with:"
echo "NODE_EXTRA_CA_CERTS=\"$NODE_EXTRA_CA_CERTS\" node your-app.js"
echo ""
echo "For npm scripts, add to package.json:"
echo "\"scripts\": {"
echo "  \"start:secure\": \"NODE_EXTRA_CA_CERTS=$NODE_EXTRA_CA_CERTS node index.js\""
echo "}"

# Verify the certificate was added
echo ""
echo "Verifying certificate in trust store..."
openssl x509 -in "$NODE_EXTRA_CA_CERTS" -text -noout | tail -5
