```
# SERVICE is the name of the Vault service in Kubernetes.
# It does not have to match the actual running service, though it may help for consistency.
SERVICE=vault-server-tls

# NAMESPACE where the Vault service is running.
NAMESPACE=vault-namespace

# SECRET_NAME to create in the Kubernetes secrets store.
SECRET_NAME=vault-server-tls

# TMPDIR is a temporary working directory.
TMPDIR=/tmp
```

https://www.vaultproject.io/docs/platform/k8s/helm/examples/standalone-tls

## Create a key for Kubernetes to sign.
```
openssl genrsa -out ${TMPDIR}/vault.key 2048
```

## Create a Certificate Signing Request (CSR) config file.

- https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster

```
cat <<EOF >${TMPDIR}/csr.conf
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = ${SERVICE}
DNS.2 = ${SERVICE}.${NAMESPACE}
DNS.3 = ${SERVICE}.${NAMESPACE}.svc
DNS.4 = ${SERVICE}.${NAMESPACE}.svc.cluster.local
IP.1 = 127.0.0.1
EOF
```

## Create the CSR.
```
openssl req -new -key ${TMPDIR}/vault.key -subj "/CN=${SERVICE}.${NAMESPACE}.svc" -out ${TMPDIR}/server.csr -config ${TMPDIR}/csr.conf
```

## Create a CertificateSigningRequest object to send to the Kubernetes API

```
export CSR_NAME=vault-csr

cat <<EOF >${TMPDIR}/csr.yaml
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: ${CSR_NAME}
spec:
  groups:
  - system:authenticated
  request: $(cat ${TMPDIR}/server.csr | base64 | tr -d '\n')
  usages:
  - digital signature
  - key encipherment
  - server auth
EOF
```

## Send the CSR to Kubernetes.
```
kubectl create -f ${TMPDIR}/csr.yaml
```

## Approve the CSR in Kubernetes.
```
kubectl certificate approve ${CSR_NAME}
```
