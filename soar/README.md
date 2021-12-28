## Ingress Access
```
clusterip=`kubectl -n ingress-nginx get svc ingress-nginx-controller -o json | jq -r '.spec.clusterIP'`
curl -vk http://${clusterip}/n8n -H 'Host: local.dev'  && echo 
```