## Install
```
helm repo add jetstack https://charts.jetstack.io && \
helm repo update && \
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.7.0 \
  --set installCRDs=true
  
```


## Verify
```
kubectl get pods --namespace cert-manager

```

## Apply the example

## Check
```
kubectl describe certificate -n cert-manager-test
```
