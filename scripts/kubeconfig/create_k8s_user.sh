#!/bin/bash
# ------------------------------------------------------------------------------ #
# Simple wrapper script generate cert & add user
version=0.2
# ------------------------------------------------------------------------------ #

# Input requires "user"
# Assumptions
# - The module will be the namespace name
# - The module will contain relevant templates

INPUT_USER=$1
csr_cfg_template="csr_cfg.template"
csr_yml_template="csr_yml.template"
kube_yml_template="kube_yml.template"

if [ $# -ne 1 ]; then
    echo "Expected arguments"
    echo "<script> <user>"
    exit 10
fi

openssl genrsa -out ${INPUT_USER}.key 4096
cat ${csr_cfg_template} | envsubst > ${INPUT_USER}-csr.cfg
openssl req -config ${INPUT_USER}-csr.cfg -new -key ${INPUT_USER}.key -nodes -out ${INPUT_USER}.csr

# export Variables to be substituted into the template
export KUBE_CRT64=$(cat ${INPUT_USER}.csr | base64 -w0)
export KUBE_KEY64=$( cat ${INPUT_USER}.key | base64 -w0 )
export BASE64_CSR=$(cat ${INPUT_USER}.csr | base64 -w0)

cat ${csr_yml_template} | envsubst | kubectl apply -f -
kubectl certificate approve ${INPUT_USER}
export K8S_CA=$( kubectl config view --raw -o json  -o jsonpath='{.clusters[].cluster.certificate-authority-data}'  )

cat ${kube_yml_template} | envsubst > ${INPUT_USER}.kubeconfig

echo "Copy ${INPUT_USER}.kubeconfig to ~/.kube/config"
echo "sudo cp ${INPUT_USER}.kubeconfig ~/.kube/config"
