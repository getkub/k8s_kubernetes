# Elastic Stack Native ECK Deployment

This repository deploys the **Elastic Cloud on Kubernetes (ECK) Operator**, a **2-node Elasticsearch cluster**, **Kibana**, and an **Elastic Agent**, with all resources natively managed via Kubernetes Custom Resource manifests.

---

## Directory Structure

```text
elastic/
├── README.md
├── version.env                 # Centralized version configuration
├── manifests/
│   ├── elasticsearch.yaml      # Elasticsearch CR manifest
│   ├── kibana.yaml             # Kibana CR manifest
│   └── elastic-agent.yaml      # Elastic Agent CR manifest
├── scripts/
│   ├── deploy-operator.sh      # Install official ECK Operator Helm chart
│   ├── deploy.sh               # Deploy Elasticsearch, Kibana, and Agent
│   ├── uninstall.sh            # Uninstall all Elastic resources
│   ├── cleanup.sh              # Cleanup all Kubernetes resources for Elastic
│   ├── create-secrets.sh       # Create required secrets
│   └── port-forward.sh         # Robust port-forwarder for Kibana
```

---

## Requirements

* Helm 3.x (only used to install the ECK Operator itself)
* `kubectl` configured to access your Kubernetes cluster
* `envsubst` (standard gettext utility) for injecting the version variable
* Sufficient storage and CPU resources for the Elasticsearch cluster
  (each node requests 20Gi storage)

---

## Deployment Steps

### 1. Deploy the ECK Operator

The operator manages the lifecycle of all Elastic Custom Resources. First, check your target versions in `version.env`:
```env
ECK_OPERATOR_VERSION="3.3.2"
ELASTIC_VERSION="9.4.0"
```

Install the operator (only needed once per cluster, or when upgrading the operator itself):
```bash
./scripts/deploy-operator.sh
```

### 2. Deploy Elasticsearch & Kibana

Deploy the stack with the target version defined in `version.env`:
```bash
./scripts/deploy.sh
./scripts/create-secrets.sh
```

`deploy.sh` will substitute the version from `version.env` into the native manifests and apply them to the cluster. The ECK operator takes over from there to spin up the pods.

### 3. Deploy Elastic Agent (Optional)

If you wish to deploy the Fleet Server and Elastic Agent, you can run the agent deployment script. This is optional and separates the complex Fleet setup from the core database setup.
```bash
./scripts/deploy-agent.sh
```

---

## Upgrading the Elastic Stack

**Do I need to uninstall and reinstall every time?** 
**No!** The ECK Operator is designed to seamlessly handle rolling upgrades without downtime.

To upgrade your Elastic Stack (Elasticsearch, Kibana, and Fleet/Agent) to a newer version:
1. Open `version.env` and change `ELASTIC_VERSION` to your target version (e.g., `9.4.0`).
2. Re-run the deploy script:
   ```bash
   ./scripts/deploy.sh
   ```
3. The ECK operator detects the version change in the manifests and gracefully orchestrates a rolling upgrade, draining and upgrading nodes one by one to ensure zero downtime.

---

## Operational Tasks

### Check Elastic Pods
```bash
kubectl get pods -n elastic-system
kubectl get pods -n elastic-agent
```

### Check Elasticsearch Cluster Health
```bash
kubectl get elasticsearch -n elastic-system
kubectl describe elasticsearch quickstart -n elastic-system
```

### Get Elasticsearch Credentials
```bash
PASSWORD=$(kubectl get secret quickstart-es-elastic-user -n elastic-system -o go-template='{{.data.elastic | base64decode}}')
echo "Elastic password: $PASSWORD"
```

### Access Kibana and Elasticsearch

1. Start the robust background port-forwarder (this prevents Kubernetes connection timeouts automatically):
   ```bash
   ./scripts/port-forward.sh
   ```
   *(Keep this script running in a background terminal. You can safely stop it by pressing `Ctrl+C`)*

2. Open [https://localhost:5601](https://localhost:5601) in your browser for Kibana. You can also use `https://localhost:9200` for Elasticsearch scripts/API calls.
3. Login using username: `elastic` and the password retrieved above.

---

## Cleanup & Removal

### Remove Elasticsearch, Kibana & Agent
If you want to tear down the data nodes and Kibana, but leave the operator intact:
```bash
./scripts/uninstall.sh
```

### Remove Operator & CRDs
If you want to remove the ECK operator and all custom resource definitions from the cluster:
```bash
./scripts/cleanup.sh
```

---

## Scale down & up

To save resources locally, you can scale the cluster down to 0 without deleting the PVCs (data):

```bash
# For Elasticsearch nodeSets
# Update your manifests/elasticsearch.yaml to count: 0, then run ./scripts/deploy.sh
# Alternatively, scale the operator so it stops reconciling, then scale StatefulSets directly:
kubectl scale statefulset elastic-operator -n elastic-system --replicas=0
kubectl scale statefulset quickstart-es-default -n elastic-system --replicas=0
kubectl scale deployment kibana-kb -n elastic-system --replicas=0
```

To scale back up:
```bash
kubectl scale statefulset elastic-operator -n elastic-system --replicas=1
# The operator will automatically restore Kibana and Elasticsearch to their desired replicas
```