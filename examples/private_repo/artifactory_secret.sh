## Get docker-server from artifactory

artifactory_server="my-dev.artifactory.mydomain.com"
artifactory_user="artadmin"
artifactory_pass="artpass"
artifactory_email="art@mydomain.com"

ns=myns

kubectl -n $ns delete secret regcred

kubectl -n $ns create secret docker-registry --docker-server=${artifactory_server} \
      --docker-username=${artifactory_user} --docker-password=${artifactory_pass}  --docker-email=${artifactory_email}
      
kubectl -n $ns get secret regcred --output="jsonpath={.data.\.dockerconfigjson}" | base64 --decode
