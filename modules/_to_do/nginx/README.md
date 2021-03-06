https://kubernetes.github.io/ingress-nginx/deploy/
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.0/deploy/static/provider/cloud/deploy.yaml
kubectl get pods --namespace=ingress-nginx
```

## Testing
- Create deployment using image and expose it
```
kubectl create deployment demo --image=httpd --port=80
kubectl expose deployment demo
```

- create an ingress resource && forward a local port to the ingress controller
```
kubectl create ingress demo-localhost --class=nginx --rule=demo.localdev.me/*=demo:80
kubectl port-forward --namespace=ingress-nginx service/ingress-nginx-controller 8080:80
```

-  GET IP address or FQDN
```
kubectl get service ingress-nginx-controller --namespace=ingress-nginx
```


## Cleanup Testing
```
kubectl delete ingress demo-localhost
kubectl delete deployment demo
```
