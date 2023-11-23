## INstall docker desktop

## Then install k3d
```
brew install k3d
k3d cluster create demo
# k3d cluster create demo --servers 3 --agents 2
kubectl cluster-info
kubectl get nodes
```


## Delete cluster
```
k3d cluster delete demo
```