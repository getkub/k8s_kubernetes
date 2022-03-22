https://operatorhub.io/operator/keycloak-operator


kubectl create -f https://raw.githubusercontent.com/operator-framework/operator-lifecycle-manager/master/deploy/upstream/quickstart/crds.yaml
kubectl create -f https://raw.githubusercontent.com/operator-framework/operator-lifecycle-manager/master/deploy/upstream/quickstart/olm.yaml


kubectl create -f https://operatorhub.io/install/keycloak-operator.yaml

kubectl get csv -n my-keycloak-operator