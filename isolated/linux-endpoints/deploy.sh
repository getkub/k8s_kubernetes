#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$DIR"

echo "Building Linux Endpoint Simulator Docker image..."
# Bypass docker-credential-desktop issue on MacOS by using an empty config
export DOCKER_CONFIG=$(mktemp -d)
echo '{"credsStore":""}' > $DOCKER_CONFIG/config.json

DOCKER_CMD=$(which docker || echo "/usr/local/bin/docker")
$DOCKER_CMD build -t linux-endpoint-simulator:latest .


echo "Importing image into k3d cluster 'cks'..."
# Fallback for k3d
K3D_CMD=$(which k3d || echo "/usr/local/bin/k3d")
$K3D_CMD image import linux-endpoint-simulator:latest -c cks

echo "Creating namespace and copying secrets..."
KUBECTL_CMD=$(which kubectl || echo "/usr/local/bin/kubectl")
$KUBECTL_CMD create namespace endpoint-simulation || true
$KUBECTL_CMD get secret quickstart-es-http-certs-public -n elastic-system -o yaml | sed 's/namespace: elastic-system/namespace: endpoint-simulation/' | $KUBECTL_CMD apply -f -
$KUBECTL_CMD get secret quickstart-es-elastic-user -n elastic-system -o yaml | sed 's/namespace: elastic-system/namespace: endpoint-simulation/' | $KUBECTL_CMD apply -f -

echo "Deploying via Helm..."
# Use helm from standard paths
HELM_CMD=$(which helm || echo "/opt/homebrew/bin/helm")
$HELM_CMD upgrade --install linux-endpoints ./chart -n endpoint-simulation

echo "Deployment complete. Use 'kubectl get pods -n endpoint-simulation' to check status."
