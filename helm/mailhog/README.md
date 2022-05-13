```
helm install mailhog codecentric/mailhog
```

```
Web UI:
=======

export POD_MAILHOG=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=mailhog,app.kubernetes.io/instance=mailhog" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward --namespace default $POD_MAILHOG 8025

SMTP Server:
============

export POD_MAILHOG=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=mailhog,app.kubernetes.io/instance=mailhog" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward --namespace default $POD_MAILHOG 1025
```