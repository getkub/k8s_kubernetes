## Steps for CA

- https://cert-manager.io/docs/configuration/ca/

- Run below setup
```
ns=cert-manager-test
kubectl apply -f ca_cert.yml

kubectl apply -f nginx_dep.yml
kubectl -n $ns get pods
kubectl -n $ns create service nodeport nginx-svc --tcp=8080:8080
# kubectl -n $ns delete service nginx-svc
kubectl -n $ns port-forward service/nginx-svc 8080:8080
```

- 