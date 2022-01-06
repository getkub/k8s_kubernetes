#!/bin/bash
# ------------------------------------------------------------------------------ #
# Simple wrapper script generate cert & add user
version=0.2
# ------------------------------------------------------------------------------ #

# Assumptions
# - INPUT_USER name is specified
# - INPUT_ROLE_MAP_ID is unique key present in ${role_mapper_file}

export INPUT_USER=$1
export INPUT_ROLE_MAP_ID=$2

role_mapper_file="role_mapper.csv"
build_dir="/tmp/create_k8_user"

export CLUSTER_SERVER="https://mycluster:6443"
csr_cfg_template="csr_cfg.template"
csr_yml_template="csr_yml.template"
kube_yml_template="kube_yml.template"

if [ $# -ne 2 ]; then
    echo "Expected arguments"
    echo "<script> <INPUT_USER> <INPUT_ROLE_MAP_ID>"
    exit 10
fi

mkdir -p ${build_dir}

xmap=`grep ${INPUT_ROLE_MAP_ID} $role_mapper_file | egrep -v '^#' | grep -v 'role_id,role_name,role_namespace' `
# Split the fields
role_id=`echo $xmap| awk -F',' '{print $1}'`
role_name=`echo $xmap| awk -F',' '{print $2}'`
role_namespace=`echo $xmap| awk -F',' '{print $3}'`
if [ -z "$role_id" ] || [ -z "$role_name" ] || [ -z "$role_namespace" ]; then
    echo "Incorrect ${INPUT_ROLE_MAP_ID}. Item NOT present in ${role_mapper_file}"
    exit 20
fi

echo "*** Starting Generating CERTS.."
echo "*** Starting Generating KEY.."
openssl genrsa -out ${build_dir}/${INPUT_USER}.key 4096
cat ${csr_cfg_template} | envsubst > ${build_dir}/${INPUT_USER}-csr.cfg
echo "*** Starting Generating CSR.."
openssl req -config ${build_dir}/${INPUT_USER}-csr.cfg -new -key ${build_dir}/${INPUT_USER}.key -nodes -out ${build_dir}/${INPUT_USER}.csr
if [ $? -ne 0 ]; then
    echo "Error in CERT generations. Exiting..."
    exit 10
fi
# export Variables to be substituted into the template
export KUBE_CRT64=$(cat ${build_dir}/${INPUT_USER}.csr | base64 | tr -d '\n')
export KUBE_KEY64=$(cat ${build_dir}/${INPUT_USER}.key | base64 | tr -d '\n' )
export BASE64_CSR=$(cat ${build_dir}/${INPUT_USER}.csr | base64 | tr -d '\n')

# Now fill up the templates
export INPUT_USER_ROLE=${role_name}
export INPUT_USER_NS=${role_namespace}
cat ${csr_yml_template} | envsubst | kubectl apply -f -
cat mappings/${role_id}.yml.template | envsubst | kubectl apply -f -

kubectl certificate approve ${build_dir}/${INPUT_USER}
export K8S_CA=$( kubectl config view --raw -o json  -o jsonpath='{.clusters[].cluster.certificate-authority-data}'  )

cat ${kube_yml_template} | envsubst > ${build_dir}/${INPUT_USER}.kubeconfig

echo "Copy ${build_dir}/${INPUT_USER}.kubeconfig to ~/.kube/config"
echo "sudo cp ${build_dir}/${INPUT_USER}.kubeconfig ~/.kube/config"
