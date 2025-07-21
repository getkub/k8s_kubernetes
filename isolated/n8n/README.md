
# n8n Helm Chart for Kubernetes

This Helm chart deploys **n8n**, an extendable workflow automation tool, on Kubernetes.  
It uses the official **n8n OCI Helm chart** and provides scripts to simplify installation, management, and cleanup.

---

## Directory Structure

```

n8n/
├── Chart.yaml              # Helm chart metadata
├── values.yaml             # n8n config (database, persistence, etc.)
├── templates/              # Helm templates (optional ingress, helpers)
│   ├── \_helpers.tpl
│   └── ingress.yaml
└── scripts/                # Deployment and management scripts
├── deploy.sh           # Install or upgrade n8n Helm chart
├── uninstall.sh        # Uninstall n8n release
└── cleanup.sh          # Remove PVCs and persistent data

````

---

## Prerequisites

- **Kubernetes cluster** (minikube, k3s, GKE, etc.)
- **Helm 3.8+**
- **kubectl** configured for your cluster
- (Optional) **Postgres** or **MySQL** database (external or managed service)

---

## Quick Start

### 1. Install n8n

```bash
./scripts/deploy.sh
````

This will:

* Create the namespace `n8n-system` (if missing).
* Install n8n from the official OCI Helm registry:
  `oci://8gears.container-registry.com/library/n8n`

---

### 2. Verify n8n Pods

```bash
kubectl get pods -n n8n-system
```

You should see something like:

```
NAME                       READY   STATUS    RESTARTS   AGE
n8n-6c6fd9d6d4-8q9d8       1/1     Running   0          2m
```

---

### 3. Access n8n (Port-Forward)

```bash
kubectl port-forward svc/n8n 5678:80 -n n8n-system
```

Then open [http://localhost:5678](http://localhost:5678).

---

### 4. Check Logs

```bash
kubectl logs deployment/n8n -n n8n-system
```

---

## Configuration

### Edit `values.yaml`

Some key configuration sections:

```yaml
config:
  database:
    type: postgresdb
    postgresdb:
      host: postgres.n8n-system.svc.cluster.local
      database: n8n
      user: n8n_user

secret:
  database:
    postgresdb:
      password: "your_postgres_password"

persistence:
  enabled: true
  size: 5Gi
```

* Use `config` for non-sensitive settings.
* Use `secret` for passwords and secrets (stored in a Kubernetes Secret).

---

## Uninstall n8n

```bash
./scripts/uninstall.sh
```

---

## Cleanup Persistent Data

To remove PVCs (persistent data):

```bash
./scripts/cleanup.sh
```

---

## Scaling n8n

n8n supports **queue mode** with Redis for horizontal scaling.

Example snippet for `values.yaml`:

```yaml
scaling:
  enabled: true
  worker:
    count: 2
  redis:
    host: "redis-host"
    password: "redis-password"
```

---

## References

* [n8n Helm Chart Documentation](https://8gears.container-registry.com/)
* [n8n Official Docs](https://docs.n8n.io/)


## Operational

- Use port-forwarding if no ingress IP is available

```
kubectl port-forward svc/n8n-stack-n8n-stack 5678:80 -n n8n-system &
```

## Scale down & up

```
kubectl scale deployment n8n-stack-n8n-stack -n n8n-system --replicas=0

kubectl scale deployment n8n-stack-n8n-stack -n n8n-system --replicas=1
```
