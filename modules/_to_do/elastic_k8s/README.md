# Elastic Cloud on Kubernetes (ECK) Setup Guide

This guide provides step-by-step instructions to deploy the Elastic Stack (Elasticsearch & Kibana) on Kubernetes using the ECK operator.

---

## 1. Prerequisites

- **Kubernetes cluster** up and running
- **kubectl** configured for your cluster
- **Persistent storage**: For production, prefer dynamic provisioning with a StorageClass. If using `hostPath`, ensure the path exists on all nodes or use node affinity.

```sh
mkdir -p /tmp/elastic/data
sudo chown -R 1000:1000 /tmp/elastic
sudo chmod -R 775 /tmp/elastic
rm -rf /tmp/elastic/data/*
ls -ld /tmp/elastic /tmp/elastic/data
```

---

## 2. Create Namespace and Storage Resources

```sh
kubectl apply -f elk_ns.yaml
kubectl apply -f elk_pv.yaml 
```

---

## 3. Install the ECK Operator

Download and apply the ECK operator manifests from Elastic:

```sh
eckv="3.0.0"
kubectl apply -f https://download.elastic.co/downloads/eck/${eckv}/crds.yaml
kubectl apply -f https://download.elastic.co/downloads/eck/${eckv}/operator.yaml
kubectl -n elastic-system logs -f statefulset.apps/elastic-operator

```

Or use your local operator manifest if present.

---

## 4. Deploy Elasticsearch

Apply the Elasticsearch manifest:

```sh
export ELK_VERSION=9.0.1
envsubst < elastic_kibana.yml | kubectl apply -f -

kubectl -n elk get pods
```


### Elastic agent. 

- Will enable the agent

```sh
export ELK_VERSION=9.0.1
envsubst < elastic_agent.yml | kubectl apply -f -

kubectl -n elk get agents
```

- Get kibana URL and creds
```
kubectl port-forward service/quickstart-kb-http -n elk 5601:5601 &
# user = elastic
kubectl get secret -n elk quickstart-es-elastic-user -o=jsonpath='{.data.elastic}' | base64 --decode; echo
```

- Using Kibana Add a fixed policy
```
POST kbn:/api/fleet/agent_policies?sys_monitoring=true
{
  "id": "fixed-kubernetes-monitoring",
  "name": "Kubernetes Monitoring",
  "description": "Fixed policy for Kubernetes monitoring",
  "namespace": "default",
  "monitoring_enabled": ["logs", "metrics"]
}

```
GET kbn:/api/fleet/agent_policies
GET kbn:/api/fleet/agent_policies/fixed-kubernetes-monitoring
```

- Should be able to access agent pods
```
kubectl -n elk get pods
```

---

## 5. Network Access (Optional: For Local LAN)

Set your variables:

```sh
mylan="192.168.2.0"
elastic_port=9210
sshUser=myuser
k8s_host="192.168.2.3"
```

Allow access to Elasticsearch port from your LAN:

```sh
sudo iptables -I INPUT -s ${mylan}/24 -p tcp --dport ${elastic_port} -j ACCEPT
sudo iptables-save >/etc/iptables/rules.v4
```

### filebeat

- Will enable the filebeat to output to /tmp/filebeat/

```sh
mkdir -p /tmp/filebeat/
export ELK_VERSION=9.0.1
envsubst < elk_filebeat.yml | kubectl apply -f -

kubectl -n elk get pods
```


---

## 6. Access Elasticsearch

Switch to the relevant namespace:

```sh
kubectl config set-context --current --namespace=elk
```

Check resources and get credentials:

```sh
kubectl get elasticsearch
kubectl get pods --selector='elasticsearch.k8s.elastic.co/cluster-name=quickstart'
kubectl get service quickstart-es-http
PASSWORD=$(kubectl get secret quickstart-es-elastic-user -o go-template='{{.data.elastic | base64decode}}')
```

Port-forward Elasticsearch to your local machine:

```sh
kubectl port-forward service/quickstart-es-http ${elastic_port}:9200 &
```

Test access:

```sh
curl -u "elastic:$PASSWORD" -k "https://localhost:${elastic_port}"
```

For remote access via SSH:

```sh
ssh -L ${elastic_port}:localhost:${elastic_port} ${sshUser}@${k8s_host}
echo https://localhost:${elastic_port}
```

Check node resources:

```sh
kubectl describe nodes
```

---

## 7. Deploy Kibana

Apply the Kibana manifest:

```sh
kubectl apply -f kibana_manifest.yaml  # Replace with your actual Kibana manifest
```

Check Kibana resources:

```sh
kubectl get kibana
kubectl get pod --selector='kibana.k8s.elastic.co/name=quickstart'
kubectl get service quickstart-kb-http
```

Set Kibana port and port-forward:

```sh
kibana_port=5610
kubectl port-forward service/quickstart-kb-http ${kibana_port}:5601 &
```

Allow access to Kibana port from your LAN:

```sh
sudo iptables -I INPUT -s ${mylan}/24 -p tcp --dport ${kibana_port} -j ACCEPT
sudo iptables-save >/etc/iptables/rules.v4
```

Get Kibana password and test access:

```sh
KIBANA_PASSWORD=$(kubectl get secret quickstart-es-elastic-user -o=jsonpath='{.data.elastic}' | base64 --decode; echo)
curl -u "elastic:${KIBANA_PASSWORD}" -k "https://localhost:${kibana_port}"
```

For remote access via SSH:

```sh
ssh -L ${kibana_port}:localhost:${kibana_port} ${sshUser}@${k8s_host}
echo https://localhost:${kibana_port}
```

Check node resources:

```sh
kubectl describe nodes
```

---

## 8. Security Best Practices

- **Do not expose Elasticsearch/Kibana directly to the internet.**
- Use **RBAC** and **network policies** for additional security.
- Regularly check resource usage and adjust requests/limits as needed.

---

**References:**
- [Elastic ECK Documentation](https://www.elastic.co/guide/en/cloud-on-k8s/current/index.html)
