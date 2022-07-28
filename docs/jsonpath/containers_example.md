```
myns=ns
mypod=pod
kubectl get pods -n $myns $mypod -o jsonpath="{.spec.containers[*].name}"
```
