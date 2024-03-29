## Fairly automated 
Check for [k8s_dashboard](../modules/k3s_dashboard) module
```
kubectl cluster-info
kubectl proxy &
```
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login


# Manual Installation
## Apply GUI package
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.4.0/aio/deploy/recommended.yaml
# Change If necessary to host which is not blocked. NOT necessary mostly as we are enabling 8443 access for LAN
# kubectl config set-cluster minikube --server=https://<samehost>:8443



### Start with localLan and how the address needs exposing
# kubectl proxy --accept-hosts='^localhost$,^192\.168\.+\..+$' --address="${k8s_host}" &
# kubectl proxy &   # This is just enough if you are port fowarding
kubectl proxy --address='0.0.0.0' --port=8001 --accept-hosts='.*' &
```

### Ensure you have an admin account in the dashboard

```

### Tokens (will take some time)
https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md
#https://github.com/kubernetes/dashboard/issues/4179
kubectl create secret generic admin-user --from-literal=admin_user=admin_pass --namespace kubernetes-dashboard 
kubectl -n kubernetes-dashboard get secret

kubectl -n kubernetes-dashboard get secrets/admin-user --template={{.data.admin_user}} |  base64 --decode

```

### In your laptop, port forward and access as localhost
```
mylan="192.168.2.1"
k8s_host="192.168.2.73"
api_port=8001
sshUser=root
ssh -L ${api_port}:localhost:${api_port} ${sshUser}@${k8s_host}
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login
```


## Steps to Generate kubeconfig


### Vars which are setup as part of the dashboard
```
export K8S_DB_USER=admin-user
#export K8S_DB_USER=kubernetes-dashboard
export K8S_NS=kubernetes-dashboard
```

### Export Variables
```
export USER_TOKEN_VALUE=$(kubectl -n ${K8S_NS} create token ${K8S_DB_USER} --duration=8760h)

export USER_TOKEN_NAME=$(kubectl -n ${K8S_NS} get serviceaccount ${K8S_DB_USER} --template='{{.metadata.name}}')

# export USER_TOKEN_VALUE=$(kubectl -n ${K8S_NS} get secret/${USER_TOKEN_NAME} --template='{{.data.admin_user}}' | base64 --decode)

export CURRENT_CONTEXT=$(kubectl config current-context)

export CURRENT_CLUSTER=$(kubectl config view --raw -o=go-template='{{range .contexts}}{{if eq .name "'''${CURRENT_CONTEXT}'''"}}{{ index .context "cluster" }}{{end}}{{end}}')

export CLUSTER_CA=$(kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}')

export CLUSTER_SERVER=$(kubectl config view --raw -o=go-template='{{range .clusters}}{{if eq .name "'''${CURRENT_CLUSTER}'''"}}{{ .cluster.server }}{{end}}{{ end }}')
```

### Now generate the kubeconfig file
```
# Changing to a temp directory would be good
cd /tmp/
```

```
cat << EOF > k8s_dashboard
apiVersion: v1
kind: Config
users:
 - name: ${K8S_NS}
   user: 
     token: ${USER_TOKEN_VALUE}
clusters:
- cluster:
    certificate-authority-data: ${CLUSTER_CA}
    server: ${CLUSTER_SERVER}
  name: ${CURRENT_CONTEXT}
contexts:
- context:
    cluster: ${CURRENT_CONTEXT}
    user: ${K8S_NS}
    namespace: ${K8S_NS}
  name: ${CURRENT_CONTEXT}
current-context: ${CURRENT_CONTEXT}
EOF
```


### Test the kubeconfig file
```
kubectl --kubeconfig $(pwd)/k8s_dashboard get all --all-namespaces
```
