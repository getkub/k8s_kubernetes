##  Will include PostGres + N8N
Steps
- Ensure Nginx in default ns
```
kubectl create deployment nginx --image=nginx
kubectl create service clusterip nginx --tcp=5678:5678
```
- Create namespace
```
kubectl create ns n8n
```
- PVC deploy
```
kubectl -n n8n apply -f 01_pvc/.
```

- Core deployment of n8n & postgres
```
kubectl -n n8n apply -f 02_deploy/.
```

- Wait for few moments for container Creation & Ready State
```
kubectl -n n8n get pods
```

- Ingress Deployment
```
kubectl -n n8n apply -f 03_ingress/.
```



## Clean-up Everything

```
kubectl -n n8n delete -f 03_ingress/.
kubectl -n n8n delete -f 02_deploy/.
kubectl -n n8n delete -f 01_pvc/.

```