## Steps for CA

- https://cert-manager.io/docs/configuration/ca/

- Run below setup
```
ns=cert-manager-test
kubectl apply -f ca_cert.yml

kubectl apply -f nginx_dep.yml
nginx_port=8081
# kubectl delete -f nginx_dep.yml
kubectl -n $ns create service nodeport nginx-svc --tcp=${nginx_port}:${nginx_port}
kubectl -n $ns get svc,pods
# kubectl -n $ns delete service nginx-svc
kubectl -n $ns port-forward service/nginx-svc ${nginx_port}:${nginx_port}
```

- 