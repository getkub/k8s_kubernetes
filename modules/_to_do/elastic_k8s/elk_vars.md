## Operator Install
```
version=2.5.0
kubectl create -f https://download.elastic.co/downloads/eck/${version}/crds.yaml
kubectl apply -f https://download.elastic.co/downloads/eck/${version}/operator.yaml
```

## Variables export
```
export ELK_VERSION=8.5.0
```

### Operator Uninstall
```
version=2.5.0
kubectl delete -f https://download.elastic.co/downloads/eck/${version}/operator.yaml
kubectl delete -f https://download.elastic.co/downloads/eck/${version}/crds.yaml
```
