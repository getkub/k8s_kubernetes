```
# After installing helm v3+ 
helm repo add codecentric https://codecentric.github.io/helm-charts
helm install keycloak codecentric/keycloak
```

## POST Installation
```
export POD_KEYCLOAK=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=keycloak,app.kubernetes.io/instance=keycloak" -o name)
echo "Visit http://127.0.0.1:8080 to use your application"
kubectl --namespace default port-forward "$POD_KEYCLOAK" 8080
```