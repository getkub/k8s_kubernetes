## Run vscode
```
ns=vscode
kport=8070
kubectl create ns $ns
helm template . --set user=vsuser --set password=secret --set namespace=${ns} | kubectl apply -f -
kubectl -n $ns get pods,svc
kubectl -n $ns port-forward service/code-server-vsuser ${kport}:${kport}
```
- Please note, the port has been overriden to `8070` as the default port is commonly used.
- If needs changing please change in `values.yaml`

## Access
```
http://your_k8s_service_ip:8070
```


## For Delete
```
ns=vscode
helm template . --set user=vsuser --set password=secret --set namespace=${ns} | kubectl delete -f -
kubectl delete ns $ns
```



## Reference
- https://hub.docker.com/r/linuxserver/code-server
- https://github.com/linuxserver/docker-code-server


## Build Own
```
docker build \
  --no-cache \
  --pull \
  -t kindocker/code-server:latest .
```

```
kport=8070
kname=k8s_code-server
mkdir -p /tmp/${kname}/config
docker run -d \
  --name=${kname} \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Europe/London \
  -e PASSWORD=secret \
  -e DEFAULT_WORKSPACE=/config/workspace \
  -p ${kport}:${kport} \
  -v /tmp/${kname}/config:/config \
  --restart unless-stopped \
  kindocker/code-server:latest
  ```