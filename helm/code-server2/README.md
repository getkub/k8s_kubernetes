## k8s CREATE
```
kubectl create ns cs
helm -n cs upgrade --install code-server helm-chart

kubectl -n cs get all
helm ls --all-namespaces
```

## k8s DELETE
```
helm -n cs uninstall code-server helm-chart
# OR
helm delete code-server
```


## Docker - For testing
```
docker run -d -p 8080:8080 kindocker/code-server2:latest
```