## Operator Install
```
version=1.8.0
kubectl create -f https://download.elastic.co/downloads/eck/${version}/crds.yaml
kubectl apply -f https://download.elastic.co/downloads/eck/${version}/operator.yaml
```

## Variables export
```
export ELK_VERSION=7.15.1
```

### Operator Uninstall
```
version=2.2.0
kubectl delete -f https://download.elastic.co/downloads/eck/${version}/operator.yaml
kubectl delete -f https://download.elastic.co/downloads/eck/${version}/crds.yaml
```
