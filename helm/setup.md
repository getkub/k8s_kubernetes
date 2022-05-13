## Ensure Tiller is configured
```
kubectl -n kube-system create serviceaccount tiller
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
helm init --service-account tiller

# verify that Tiller is running
kubectl get pods --namespace kube-system
helm init

```
