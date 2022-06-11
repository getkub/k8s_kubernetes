- https://coder.com/docs/code-server/latest/helm

## Install
```
git clone https://github.com/coder/code-server
cd code-server
helm upgrade --install code-server ci/helm-chart
```

## Uninstall
```
helm delete code-server
```


### For other values
```
helm upgrade --install code-server ci/helm-chart -f values.yaml
```