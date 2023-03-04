Generated automatically

```
splunk/
  Chart.yaml
  values.yaml
  templates/
    deployment.yaml
    service.yaml
    persistent-volume-claims.yaml
```

```
mkdir splunk-helm-chart
cd splunk-helm-chart
helm create splunk

```


```
helm package splunk
helm install my-splunk splunk-0.1.0.tgz
```