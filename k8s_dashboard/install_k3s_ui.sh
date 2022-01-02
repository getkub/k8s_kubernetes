#!/bin/bash
# ---------------------------------- #
# Simple script to install kubernetes dashboard
# ---------------------------------- #

kconfig="/tmp/kubeconfig"

if [ -f "$kconfig" ]; then
    export KUBECONFIG=${kconfig}
else
   echo "Expected kubeconfig ${kconfig} NOT found. Exiting..."
   exit 100
fi


GITHUB_URL=https://github.com/kubernetes/dashboard/releases
VERSION_KUBE_DASHBOARD=$(curl -w '%{url_effective}' -I -L -s -S ${GITHUB_URL}/latest -o /dev/null | sed -e 's|.*/||')

# Assuming k3sup is all setup. So below will be installed on the remote
kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/${VERSION_KUBE_DASHBOARD}/aio/deploy/recommended.yaml

## All in one yaml for kubernetes dashboard
kubectl apply -f k3s_dashboard_all.yaml

echo "Installation complete..."