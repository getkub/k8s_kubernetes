## Ingress Access
```
clusterip=`kubectl -n ingress-nginx get svc ingress-nginx-controller -o json | jq -r '.spec.clusterIP'`
curl -vk https://${clusterip}/n8n -H 'Host: svc1.local.dev'
```