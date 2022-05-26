# Store key, cert, and Kubernetes CA into Kubernetes secrets store

## Retrieve the certificate.
```
serverCert=$(kubectl get csr ${CSR_NAME} -o jsonpath='{.status.certificate}')
```

##  Write the certificate out to a file.
```
echo "${serverCert}" | openssl base64 -d -A -out ${TMPDIR}/vault.crt
```

## Retrieve Kubernetes CA.
```
kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}' | base64 -d > ${TMPDIR}/vault.ca
```

## Namespace create
```
kubectl create namespace ${NAMESPACE}
```

## Store in K8S secrets
```
kubectl create secret generic ${SECRET_NAME} \
        --namespace ${NAMESPACE} \
        --from-file=vault.key=${TMPDIR}/vault.key \
        --from-file=vault.crt=${TMPDIR}/vault.crt \
        --from-file=vault.ca=${TMPDIR}/vault.ca
```
