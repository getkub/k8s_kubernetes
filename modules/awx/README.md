# Operator
```
# This is now deprecated
kubectl apply -f https://raw.githubusercontent.com/ansible/awx-operator/devel/deploy/awx-operator.yaml
```


## New method: build from scratch
```
cd /tmp/
git clone https://github.com/ansible/awx-operator.git
cd awx-operator
export NS=awx
make deploy
cd config/manager && ../../bin/kustomize edit set image controller=quay.io/ansible/awx-operator:0.14.0 && cd -
./bin/kustomize build config/default | kubectl apply -f -

kubectl -n $NS get pods
```


## Prebuilt
```
export NS=awx
kubectl -n $NS apply -f built_operator/awx-operator.yml
kubectl -n $NS get pods
```


## Apply modules
```
# At modules directory level
./control_k8s.sh awx apply
kubectl -n awx get all
```

## Post Setup
```
# Log to the relevant pod and container
kubectl -n awx get pod
pod="awx-64bc58f8d6-6j5pv"
kubectl -n awx exec -it $pod -c awx-web -- /bin/bash
awx-manage createsuperuser --username awx --email awx@dev.test

http://<clusterip>:9080/home
```