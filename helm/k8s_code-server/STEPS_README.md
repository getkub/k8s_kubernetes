## Run vscode
```
ns=vscode
kubectl create ns $ns
helm template . --set user=vsuser --set password=secret --set namespace=${ns} | kubectl apply -f -

kubectl -n vscode port-forward service/code-server-vsuser 8443:8443
```

## For Delete
```
ns=vscode
helm template . --set user=vsuser --set password=secret --set namespace=${ns} | kubectl delete -f -
kubectl delete ns $ns
```



## to check
https://hub.docker.com/r/linuxserver/code-server
https://github.com/linuxserver/docker-code-server


## Build Own
```
docker build \
  --no-cache \
  --pull \
  -t kindocker/code-server:latest .
```

```
mkdir -p /tmp/k8s_code-server/config
docker run -d \
  --name=k8s_code-server \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Europe/London \
  -e PASSWORD=secret \
  -e DEFAULT_WORKSPACE=/config/workspace \
  -p 8443:8443 \
  -v /tmp/k8s_code-server/config:/config \
  --restart unless-stopped \
  kindocker/code-server:latest
  ```