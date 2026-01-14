#!/bin/bash

set -e

CA_DIR="../ca"
CA_KEY="$CA_DIR/ca.key"
CA_CERT="$CA_DIR/ca.crt"
CA_CONFIG="$CA_DIR/openssl.cnf"

echo "Generating CA private key..."
openssl genrsa -out "$CA_KEY" 4096

echo "Generating CA certificate..."
openssl req -new -x509 -days 3650 -key "$CA_KEY" -sha256 -out "$CA_CERT" -config "$CA_CONFIG" -extensions v3_ca

echo "CA certificate generated successfully!"
echo "CA Key: $CA_KEY"
echo "CA Certificate: $CA_CERT"

# Display certificate info
echo ""
echo "Certificate Information:"
openssl x509 -in "$CA_CERT" -text -noout | head -20
