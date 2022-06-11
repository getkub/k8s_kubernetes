## To CREATE
```
kubectl create ns cs
helm -n cs upgrade --install code-server helm-chart

kubectl -n cs get all
helm ls --all-namespaces
```

## To DELETE
```
helm -n cs uninstall code-server helm-chart
# OR
helm delete code-server
```