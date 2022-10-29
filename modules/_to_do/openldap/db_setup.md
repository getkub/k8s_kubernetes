
https://docs.bitnami.com/tutorials/create-openldap-server-kubernetes/
```
# helm search repo -l demo/mariadb-galera
helm repo add bitnami https://charts.bitnami.com/bitnami

Don't do below, but download the values.yml and edit it
#helm install my-release bitnami/mariadb-galera
helm uninstall -n db my-release
kubectl -n db get pvc # and cleanup pvc
kubectl -n db delete pvc data-my-release-mariadb-galera-0 data-my-release-mariadb-galera-1 data-my-release-mariadb-galera-2
```

** Amend values :  values.yaml **

```
kubectl create ns db
helm install -f mariadb_values.yml -n db my-release bitnami/mariadb-galera
kubectl -n db get sts -l app.kubernetes.io/instance=my-release
kubectl -n db get service

```

### Test connections
```
ns="ldap"
echo "$(kubectl get secret openldap -n $ns -o json | jq -r .data.users | base64 --decode)"
echo "$(kubectl get secret openldap -n $ns -o json | jq -r .data.passwords | base64 --decode)"


## These happen in default namespace
kubectl -n db get pods
maria_image="docker.io/bitnami/mariadb-galera:10.6.10-debian-11-r11"
maria_pod="release-mariadb-galera"
kubectl -n db run $maria_pod --rm -it --image $maria_image --env ALLOW_EMPTY_PASSWORD=yes -- bash
# Wait for few minutes

kubectl -n db exec -it $maria_pod -- bash
# mysql -h my-release-mariadb-galera -u user01 -ppassword01 my_database
kubectl -n db logs $maria_pod

```


```
kubectl -n db get pods
maria_image="docker.io/bitnami/mariadb-galera:10.6.10-debian-11-r11"
maria_pod="release-mariadb-galera"

  Watch the deployment status using the command:

    kubectl -n db get sts -n db -l app.kubernetes.io/instance=my-release

MariaDB can be accessed via port "3306" on the following DNS name from within your cluster:

    ${maria_pod}.default.svc.cluster.local

To obtain the password for the MariaDB admin user run the following command:

    echo "$(kubectl get secret -n db my-${maria_pod} -o jsonpath="{.data.mariadb-root-password}" | base64 --decode)"

To connect to your database run the following command:

    kubectl -n db run my-release-mariadb-galera-client --rm --tty -i --restart='Never' -n db --image $maria_image 
    kubectl -n db exec ${maria_pod} -- mysql -h my-${maria_pod} -P 3306 -uroot -p$(kubectl get secret -n db my-${maria_pod} -o jsonpath="{.data.mariadb-root-password}" | base64 --decode) my_database

To connect to your database from outside the cluster execute the following commands:

    kubectl port-forward -n db svc/my-${maria_pod} 3306:3306 &
    mysql -h 127.0.0.1 -P 3306 -uroot -p$(kubectl get secret -n db ${maria_pod} -o jsonpath="{.data.mariadb-root-password}" | base64 --decode) my_database

To upgrade this helm chart:

    helm upgrade -n db my-release bitnami/mariadb-galera \
      --set rootUser.password=$(kubectl get secret -n db my-release-mariadb-galera -o jsonpath="{.data.mariadb-root-password}" | base64 --decode) \
      --set db.name=my_database \
      --set galera.mariabackup.password=$(kubectl get secret -n db my-release-mariadb-galera -o jsonpath="{.data.mariadb-galera-mariabackup-password}" | base64 --decode)
      ```
