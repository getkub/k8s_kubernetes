## Restart Daemonset
```
myns=somens
myds=someds
kubectl -n $myns rollout restart daemonset $myds
```
