## Test app
- Ensure this is run within its own namespace

```
ns="something"
# Ensure tls-secret is loaded into same namespace
kubectl -n $ns apply -f echo_app.yml
kubectl -n $ns apply -f ../k8s-learn/secret/tls-secret.yaml
kubectl -n $ns apply -f echo_ingress.yml

```

Now access the URL
- https://mydev2.test/banana
- https://mydev2.test/apple