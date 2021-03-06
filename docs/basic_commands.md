

### K8s commands
```
export KUBECONFIG=/tmp/somekubeConfig
kubectl version --short
ns="default"
kubectl config set-context $(kubectl config current-context) --namespace=${ns}
nodename=localhost

podname=""
kubectl get deployment -n ${ns}
kubectl get pods -n ${ns}
kubectl get pods --all-namespaces
kubectl get pod ${podname} -n ${ns} -o yaml
kubectl describe node  $nodename
```

### Scale within deployment
```
kubectl get deployment -n ${ns}
kubectl scale --current-replicas=2 --replicas=3 deployment/nginx-deployment -n ${ns}
kubectl scale --replicas=4 deployment/nginx-deployment -n ${ns}
```

### Running in a loop
```
for mypv in $(kubectl get pv -o jsonpath="{.items[*].metadata.name}" | grep -v Terminating);
do
  # kubectl patch pv $mypv -p '{"metadata":{"finalizers":null}}'
  kubectl get pods
done
```
