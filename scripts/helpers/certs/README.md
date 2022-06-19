## Sample CA for kubernetes testing
- https://github.com/cert-manager/cert-manager/issues/279

The helper script will 
- Generate key
- Generate crt for macos
- Load the CRT with relevant properties to `certs` namespace of k8s

```
sh ./gen_cert.sh
```

## To apply to another namespace
```
ns=something
kubectl -n $ns apply -f tls-secret.yml
```