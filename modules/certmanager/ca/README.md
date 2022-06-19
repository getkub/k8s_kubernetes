## Steps for CA

- https://cert-manager.io/docs/configuration/ca/

- Run below setup
```
ns=cert-manager-test
# Apply tls-secret beforehand (This will be the CA authority)
kubectl -n $ns apply -f ../../../scripts/helpers/certs/tls-secret.yml
kubectl apply -f ca_cert.yml
kubectl -n $ns get issuers ca-issuer  -o wide

```

- Run the `echo` application

- Apply Ingress
```
kubectl apply -f echo_ingress.yml
```