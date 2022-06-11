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
docker stop cs2
docker rm $(docker ps -a -f status=exited -q)
docker run --name cs2 -d -it -p 127.0.0.1:8080:8080 kindocker/code-server2:latest

```