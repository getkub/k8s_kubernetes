## Installing the Splunk Operator
```
opVersion=1.1.0
kubectl apply -f https://github.com/splunk/splunk-operator/releases/download/${opVersion}/splunk-operator-install.yaml
ns=splunk
kubectl create -n $ns
kubectl -n $ns port-forward service/splunk-single-standalone-service 8000:8000 
``` 

## Creds
```
ns=splunk
# kubectl -n $ns get secret splunk-${ns}-secret -o yaml
kubectl -n $ns get secret splunk-${ns}-secret -o=jsonpath='{.data.password}'| base64 --decode; echo


## Below fails for time being
newpass="someComplexpass"
newpass_encoded=`echo -n $newpass | base64`
kubectl -n $ns patch secret splunk-${ns}-secret -p='{"data":{"password": "'$newpass_encoded'" }}' -v=2
```


## Advanced Examples
- https://splunk.github.io/splunk-operator/Examples.html
