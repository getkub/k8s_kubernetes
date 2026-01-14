#!/bin/bash

set -e

# Detect OS and set default Splunk home
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    SPLUNK_HOME="${SPLUNK_HOME:-/Applications/Splunk}"
else
    # Linux/Unix
    SPLUNK_HOME="${SPLUNK_HOME:-/opt/splunk}"
fi
APP_NAME="my_splunk_certs"
APP_DIR="$SPLUNK_HOME/etc/apps/$APP_NAME"
CERTS_DIR="$APP_DIR/local/certs"

# Check if certificates exist
if [ ! -f "../splunk/splunk.crt" ] || [ ! -f "../splunk/splunk.key" ] || [ ! -f "../ca/ca.crt" ]; then
    echo "Error: Splunk certificates not found. Please run generate-splunk-cert.sh first."
    exit 1
fi

echo "Creating Splunk app: $APP_NAME"

# Create app directory structure
mkdir -p "$CERTS_DIR"
mkdir -p "$APP_DIR/default"
mkdir -p "$APP_DIR/metadata"

# Copy certificates
echo "Copying certificates to app..."
cp "../splunk/splunk.crt" "$CERTS_DIR/"
cp "../splunk/splunk.key" "$CERTS_DIR/"
cp "../ca/ca.crt" "$CERTS_DIR/"

# Create app.conf
cat << EOF | tee "$APP_DIR/default/app.conf" > /dev/null
[ui]
is_visible = 0
is_manageable = 0

[launcher]
author = Local Development
description = SSL Certificates for local development
version = 1.0.0

[package]
id = my_splunk_certs
EOF

# Remove any existing web.conf to avoid conflicts
rm -f "$APP_DIR/local/web.conf"

# Create mcp.conf for SSL verification
cat << EOF | tee "$APP_DIR/local/mcp.conf" > /dev/null
[server]
ssl_verify = $SPLUNK_HOME/etc/apps/my_splunk_certs/local/certs/ca.crt
EOF

# Create metadata file
cat << EOF | tee "$APP_DIR/metadata/local.meta" > /dev/null
[]
access = read : [ * ], write : [ admin ]
export = system
EOF

# Set proper permissions
# echo "Setting permissions..."
# chown -R splunk:splunk "$APP_DIR"
chmod 600 "$CERTS_DIR"/*.key
chmod 644 "$CERTS_DIR"/*.crt

echo "Splunk app created successfully!"
echo "App location: $APP_DIR"
echo ""
echo "To activate the app, restart Splunk:"
echo "$SPLUNK_HOME/bin/splunk restart"
echo ""
echo "The app contains:"
echo "- Certificates in: $CERTS_DIR/"
echo "- Web configuration in: $APP_DIR/local/web.conf"
echo "- MCP configuration in: $APP_DIR/local/mcp.conf"
echo ""
