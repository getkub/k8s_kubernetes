https://medium.com/@harsh.manvar111/kubernetes-nginx-ingress-and-cert-manager-ssl-setup-c82313703d0d

### Pre-Reqs

- Run nginx (separate directory) before this


https://kubernetes.github.io/ingress-nginx/examples/tls-termination/
https://kubernetes.github.io/ingress-nginx/examples/PREREQUISITES/



```
kubectl get svc -n ingress-nginx
NAME                                 TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx-controller             LoadBalancer   10.109.212.57    <pending>     80:30427/TCP,443:30253/TCP   56m
ingress-nginx-controller-admission   ClusterIP      10.100.214.225   <none>        443/TCP                      56m
```
- The LoadBalancer IP will be used to display services inside

```
curl -vk https://10.109.212.57/ -H 'Host: svc1.local.dev'
curl -vk https://10.109.212.57/ -H 'Host: svc2.local.dev'
```
