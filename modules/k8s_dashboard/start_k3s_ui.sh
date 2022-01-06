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

# Obtain the Bearer Tokenlink
kubectl -n kubernetes-dashboard describe secret admin-user-token | grep '^token'

# Local Access to the Dashboardlink
kubectl proxy & 

echo ""
echo "***** kubernetes dashboard Started. Please navigate to below URL ****"
echo 'http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/'
echo ""