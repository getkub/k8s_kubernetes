## Run vscode
```
ns=vscode
kubectl create ns $ns
helm template . --set user=vsuser --set password=secret --set namespace=${ns} | kubectl apply -f -

kubectl -n vscode port-forward service/code-server-vsuser 8070:8070
```

## For Delete
```
ns=vscode
helm template . --set user=vsuser --set password=secret --set namespace=${ns} | kubectl delete -f -
kubectl delete ns $ns
```


