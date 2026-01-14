#!/bin/bash

set -e

# Configuration
CA_DIR="../ca"
SPLUNK_DIR="../splunk"
CA_CERT="$CA_DIR/ca.crt"
CA_KEY="$CA_DIR/ca.key"
SPLUNK_KEY="$SPLUNK_DIR/splunk.key"
SPLUNK_CERT="$SPLUNK_DIR/splunk.crt"
SPLUNK_CSR="$SPLUNK_DIR/splunk.csr"
SPLUNK_CONFIG="$SPLUNK_DIR/openssl.cnf"

# Check if CA exists
if [ ! -f "$CA_CERT" ] || [ ! -f "$CA_KEY" ]; then
    echo "Error: CA certificate and key not found. Please run generate-ca.sh first."
    exit 1
fi

echo "Generating Splunk private key..."
openssl genrsa -out "$SPLUNK_KEY" 2048

echo "Generating Splunk certificate signing request..."
openssl req -new -key "$SPLUNK_KEY" -out "$SPLUNK_CSR" -config "$SPLUNK_CONFIG"

echo "Signing Splunk certificate with CA..."
openssl x509 -req -days 365 -in "$SPLUNK_CSR" -CA "$CA_CERT" -CAkey "$CA_KEY" -CAcreateserial -out "$SPLUNK_CERT" -sha256 -extfile "$SPLUNK_CONFIG" -extensions v3_req

echo "Splunk certificate generated successfully!"
echo "Splunk Key: $SPLUNK_KEY"
echo "Splunk Certificate: $SPLUNK_CERT"

# Clean up CSR
rm -f "$SPLUNK_CSR"

# Display certificate info
echo ""
echo "Splunk Certificate Information:"
openssl x509 -in "$SPLUNK_CERT" -text -noout | grep -E "(Subject:|Issuer:|Not Before:|Not After:|Subject Alternative Name:)" | head -10

echo ""
echo "To verify the certificate chain:"
echo "openssl verify -CAfile $CA_CERT $SPLUNK_CERT"

echo ""
echo "For Splunk configuration, use these files:"
echo "- Server certificate: $SPLUNK_CERT"
echo "- Private key: $SPLUNK_KEY"
echo "- CA certificate: $CA_CERT (for client verification if needed)"
