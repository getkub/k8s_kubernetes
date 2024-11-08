## Setup of logstash in Azure


### Kubectl creating a test deployment
```
kubectl create deploy test --image mcr.microsoft.com/azure-cli/tools:0.2.1 -- sh -c "sleep infinity"

# Test connection to an Azure service
kubectl exec -it deploy/test -- bash -c "curl https://myapp.someService.windows.net:443 -vk"
```

### Download & install logstash
```
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | gpg --dearmor -o /usr/share/keyrings/elastic-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/elastic-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-8.x.list
apt-get update && apt-get install logstash 

```
