Understood! Here’s the **entire README.md content as plain text** — **no triple backticks at all**, so you can just copy-paste it directly without Markdown breaking or mixing code fences.

---

# Elastic Stack Helm Chart (with ECK Operator)

This Helm chart deploys the **Elastic Cloud on Kubernetes (ECK) Operator**, a **3-node Elasticsearch 9.0.3 cluster**, and **Kibana 9.0.3**, with all resources organized for Kubernetes.

---

## Directory Structure

```
elastic/
├── README.md
├── Chart.yaml              # Helm chart metadata for ES + Kibana (CRDs)
├── values.yaml             # Values for Elasticsearch, Kibana, Beats config
├── templates/
│   ├── elasticsearch.yaml  # Elasticsearch CR manifest template
│   ├── kibana.yaml         # Kibana CR manifest template
│   ├── beats.yaml          # Beats CR manifest template (optional)
│   ├── ingress.yaml        # Ingress for Kibana or ES (optional)
│   └── \_helpers.tpl        # Helm helper templates
├── scripts/
│   ├── deploy-operator.sh  # Install official ECK Operator Helm chart
│   ├── deploy.sh           # Deploy your ES/Kibana Helm chart (CRs)
│   ├── uninstall.sh        # Uninstall ES/Kibana Helm release + operator
│   └── cleanup.sh          # Cleanup all Kubernetes resources for Elastic
```
---

## Requirements

* Helm 3.x
* kubectl configured to access your Kubernetes cluster
* Sufficient storage and CPU resources for a **3-node Elasticsearch cluster**
  (each node requests 20Gi storage, 500m CPU, 2Gi memory)

---

## Deployment Steps

### 1. Deploy the ECK Operator

Run:
```
kubectl apply -f your-operator-yaml-or-run
OR
./scripts/deploy-operator.sh
```
---

### 2. Deploy Elasticsearch & Kibana

Run:
```
./scripts/deploy.sh
```
This deploys:

* Elasticsearch 9.0.3 (3-node cluster)
* Kibana 9.0.3 (1 replica)

---

## Operational Tasks

### Check Elastic Pods
```
kubectl get pods -n elastic-system
```
### Check Elasticsearch Cluster Health

kubectl get elasticsearch -n elastic-system
kubectl describe elasticsearch quickstart -n elastic-system

### Get Elasticsearch Credentials

```
PASSWORD=$(kubectl get secret quickstart-es-elastic-user -n elastic-system -o go-template='{{.data.elastic | base64decode}}')
echo "Elastic password: $PASSWORD"
```

### Access Kibana

1. Port-forward Kibana service:
```
kubectl port-forward service/kibana-kb-http 5601 -n elastic-system &
```
2. Open [https://localhost:5601](https://localhost:5601) in your browser
3. Login using username: elastic and the password from above

---

## Cleanup

### Remove Elasticsearch & Kibana
```
./scripts/uninstall.sh
```
### Remove Operator & CRDs
```
./scripts/cleanup.sh
```
---

## Notes

* Elasticsearch and Kibana versions are controlled via values.yaml
* Modify templates/elasticsearch.yaml and templates/kibana.yaml to adjust replicas, resources, or storage classes

---

## Scale down & up

```
# For Elastic operator statefulset
kubectl scale statefulset elastic-operator -n elastic-system --replicas=0

# For Elasticsearch StatefulSet (assuming name 'quickstart-es')
kubectl scale statefulset quickstart-es -n elastic-system --replicas=0

# For Kibana deployment (assuming name 'kibana-kb')
kubectl scale deployment kibana-kb -n elastic-system --replicas=0

```

```
kubectl scale statefulset elastic-operator -n elastic-system --replicas=1
kubectl scale statefulset quickstart-es -n elastic-system --replicas=3
kubectl scale deployment kibana-kb -n elastic-system --replicas=1
```