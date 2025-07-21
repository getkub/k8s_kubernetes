#!/bin/bash
set -e

NAMESPACE="n8n-system"

echo ">>> Uninstalling n8n-stack Helm release"
helm uninstall n8n-stack -n "$NAMESPACE" || true
