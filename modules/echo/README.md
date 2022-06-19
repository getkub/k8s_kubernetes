## Test app
- Ensure this is run within its own namespace

```
ns="something"
pf=5678

kubectl -n $ns apply -f echo_app.yml

kubectl -n $ns port-forward ingress/echo-ingress ${pf}:${pf}

```