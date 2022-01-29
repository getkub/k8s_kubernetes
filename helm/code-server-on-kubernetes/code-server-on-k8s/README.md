## Run vscode
```
ns=vscode
kubectl create ns $ns
helm template . --set user=vsuser --set password=secret --set namespace=${ns} | kubectl apply -f -
```


## For Delete
```
ns=vscode
helm template . --set user=vsuser --set password=secret --set namespace=${ns} | kubectl delete -f -
kubectl delete ns $ns
```