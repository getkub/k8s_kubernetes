#!/bin/bash

set -e

# Configuration
CA_DIR="../ca"
SERVER_DIR="../server"
CA_CERT="$CA_DIR/ca.crt"
CA_KEY="$CA_DIR/ca.key"
SERVER_KEY="$SERVER_DIR/server.key"
SERVER_CERT="$SERVER_DIR/server.crt"
SERVER_CSR="$SERVER_DIR/server.csr"
SERVER_CONFIG="$SERVER_DIR/openssl.cnf"

# Check if CA exists
if [ ! -f "$CA_CERT" ] || [ ! -f "$CA_KEY" ]; then
    echo "Error: CA certificate and key not found. Please run generate-ca.sh first."
    exit 1
fi

echo "Generating server private key..."
openssl genrsa -out "$SERVER_KEY" 2048

echo "Generating server certificate signing request..."
openssl req -new -key "$SERVER_KEY" -out "$SERVER_CSR" -config "$SERVER_CONFIG"

echo "Signing server certificate with CA..."
openssl x509 -req -days 365 -in "$SERVER_CSR" -CA "$CA_CERT" -CAkey "$CA_KEY" -CAcreateserial -out "$SERVER_CERT" -sha256 -extfile "$SERVER_CONFIG" -extensions v3_req

echo "Server certificate generated successfully!"
echo "Server Key: $SERVER_KEY"
echo "Server Certificate: $SERVER_CERT"

# Clean up CSR
rm -f "$SERVER_CSR"

# Display certificate info
echo ""
echo "Server Certificate Information:"
openssl x509 -in "$SERVER_CERT" -text -noout | grep -E "(Subject:|Issuer:|Not Before:|Not After:|Subject Alternative Name:)" | head -10

echo ""
echo "To verify the certificate chain:"
echo "openssl verify -CAfile $CA_CERT $SERVER_CERT"
