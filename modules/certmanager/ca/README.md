## Steps for CA

- https://cert-manager.io/docs/configuration/ca/

- Run below setup
```
ns=cert-manager-test
# Apply tls-secret beforehand
kubectl -n $ns apply -f ../k8s-learn/secret/tls-secret.yaml
kubectl apply -f ca_cert.yml

```

- 