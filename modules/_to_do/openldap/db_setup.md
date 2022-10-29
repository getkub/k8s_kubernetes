
https://docs.bitnami.com/tutorials/create-openldap-server-kubernetes/
```
# helm search repo -l demo/mariadb-galera
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-release bitnami/mariadb-galera

```

** Amend values :  values.yaml **


```
helm install -f values.yaml my-release demo/mariadb-galera
kubectl get sts -l app.kubernetes.io/instance=my-release
kubectl get service

```

### Test connections
```
ns="ldap"
echo "$(kubectl get secret openldap -n $ns -o json | jq -r .data.users | base64 --decode)"
echo "$(kubectl get secret openldap -n $ns -o json | jq -r .data.passwords | base64 --decode)"


## These happen in default namespace
kubectl get pods
maria_image="docker.io/bitnami/mariadb-galera:10.6.4-debian-10-r30"
maria_pod="mariadb-galera-client"
kubectl run $maria_pod --rm --tty -i --restart='Never' --namespace default --image $maria_image
kubectl exec -it $maria_pod -- bash
# mysql -h my-release-mariadb-galera -u user01 -ppassword01 my_database
kubectl logs $maria_pod

```


```
kubectl get pods
maria_image="docker.io/bitnami/mariadb-galera:10.6.4-debian-10-r30"
maria_pod2="release-mariadb-galera"

  Watch the deployment status using the command:

    kubectl get sts -w --namespace default -l app.kubernetes.io/instance=my-release

MariaDB can be accessed via port "3306" on the following DNS name from within your cluster:

    my-release-mariadb-galera.default.svc.cluster.local

To obtain the password for the MariaDB admin user run the following command:

    echo "$(kubectl get secret --namespace default my-release-mariadb-galera -o jsonpath="{.data.mariadb-root-password}" | base64 --decode)"

To connect to your database run the following command:

    kubectl run my-release-mariadb-galera-client --rm --tty -i --restart='Never' --namespace default --image $maria_image 
    kubectl exec my-${maria_pod2}-client -- mysql -h my-${maria_pod2} -P 3306 -uroot -p$(kubectl get secret --namespace default my-${maria_pod2} -o jsonpath="{.data.mariadb-root-password}" | base64 --decode) my_database

To connect to your database from outside the cluster execute the following commands:

    kubectl port-forward --namespace default svc/my-${maria_pod2} 3306:3306 &
    mysql -h 127.0.0.1 -P 3306 -uroot -p$(kubectl get secret --namespace default my-${maria_pod2} -o jsonpath="{.data.mariadb-root-password}" | base64 --decode) my_database

To upgrade this helm chart:

    helm upgrade --namespace default my-release bitnami/mariadb-galera \
      --set rootUser.password=$(kubectl get secret --namespace default my-release-mariadb-galera -o jsonpath="{.data.mariadb-root-password}" | base64 --decode) \
      --set db.name=my_database \
      --set galera.mariabackup.password=$(kubectl get secret --namespace default my-release-mariadb-galera -o jsonpath="{.data.mariadb-galera-mariabackup-password}" | base64 --decode)
      ```
