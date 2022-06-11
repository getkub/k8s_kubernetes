- https://coder.com/docs/code-server/latest/helm
- https://docs.microsoft.com/en-us/azure/developer/ansible/configure-in-docker-container?tabs=azure-cli

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