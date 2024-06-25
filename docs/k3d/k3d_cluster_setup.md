## Cluster create
```
clusterName=cks
k3d cluster create --servers 1 ${clusterName}
# Will create with k3d prefix
k3d node list
```

### Node Create
```
k3d node create --cluster ${clusterName} ${clusterName}-worker
k3d node list ## Ensure it is created within correct Cluster
kubectl get nodes
```
