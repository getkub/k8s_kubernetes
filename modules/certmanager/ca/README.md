## Steps for CA

- https://cert-manager.io/docs/configuration/ca/

- Run below setup
```
ns=cert-manager-test
# Apply tls-secret beforehand
kubectl -n $ns apply -f ../../../scripts/helpers/certs/tls-secret.yml
kubectl apply -f ca_cert.yml
kubectl -n $ns get issuers ca-issuer  -o wide

```

- 