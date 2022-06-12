Complete Container with Ansible & Python with VSCode

## About this Project
code-server is VS Code running on a remote server, accessible through the browser.
This is a FULL image on Ubuntu with Ansible & Python3 baked in for development prowness
Original Project - https://github.com/cdr/code-server

## Run vscode
```
ns=vscode
kport=8443
kubectl create ns $ns
helm template . --set user=vsuser --set password=secret --set namespace=${ns} | kubectl apply -f -
kubectl -n $ns get pods,svc
kubectl -n $ns port-forward service/code-server-vsuser ${kport}:${kport}
```

## Access
```
http://your_k8s_service_ip:8443
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
kport=8443
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
  kindocker/k8s_code-server:latest
  ```