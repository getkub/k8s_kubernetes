# 🖥️ Linux Endpoint Simulators Walkthrough

I have successfully provisioned a dedicated Helm chart at `isolated/linux-endpoints` that creates standalone "Linux boxes" running as standard deployments inside your Kubernetes cluster.

These endpoints give you the perfect simulation environment for Elastic data generation (like failed logins, process creations, or sudo violations) without muddying up your cluster's worker node OS logs or worrying about breaking your actual host Linux environments!

## Architecture Summary

Instead of running the complex daemonset agent natively on the host nodes, we've deployed isolated Kubernetes pods using a custom Ubuntu base image pre-loaded with standard Linux administrative dependencies.

- **Base Image:** `ubuntu:24.04`
- **Installed Tools:** `sshd`, `rsyslog`, `sudo`, `curl`, and standard chrony tasks.
- **Agent Version:** `elastic-agent:8.17.0` running natively within the container.
- **Agent Config:** Uses **Fleet-managed** mode, dynamically enrolling at startup via `entrypoint.sh` using your defined Kibana Fleet Enrollment Token. It automatically pulls down integrations like `System` or `Custom Logs` to securely ship `/var/log/auth.log` and `/var/log/syslog`.
## ⚙️ Kibana Fleet Setup (Required)

Because the endpoints are dynamically managed by Fleet, you **must** configure Kibana's internal global Fleet Settings correctly so the agents know where to communicate.

1. Open **Kibana** (`https://localhost:5601`) and navigate to **Fleet -> Settings**.
2. **Fleet Server Hosts**: Edit or add a host pointing to the internal Kubernetes service created by ECK:
   ```text
   https://elastic-agent-agent-http.elastic-agent.svc.cluster.local:8220
   ```
3. **Outputs**: Edit the `default` Elasticsearch output to point to the ECK Elasticsearch service:
   ```text
   https://quickstart-es-http.elastic-system.svc.cluster.local:9200
   ```
4. **Bypass Self-Signed Certificates**: In the **Outputs** setting, scroll down to the **Advanced YAML configuration** box and add:
   ```yaml
   ssl.verification_mode: none
   ```
5. **Save and Apply**. This ensures your endpoints don't crash with `x509: certificate signed by unknown authority` or bad DNS lookups when attempting to fetch policies or ship metrics!

> [!WARNING]
> Do **not** add the `Elastic Defend` integration to your simulated Linux policy. Elastic Defend requires host-level `systemd` and exclusive kernel eBPF access, which will conflict and fail inside these shared-kernel Docker containers. Use the **System** integration instead.

## Check Your Live Simulation Fleet

The simulators are grouped inside their own namespace, decoupled from your main Elastic workloads.

```bash
kubectl get pods -n endpoint-simulation
```

You will see replicas like `linux-endpoints-xxx` fully running.

## Generating Brute Force Test Data

Because the simulators have SSH running inside them, and are actively monitored by the native agent, you can very easily jump into them directly using `kubectl exec` and simulate anything from local command-line abuse to SSH brute-force campaigns!

### 1. Generating Invalid Logins natively

The easiest way to simulate SSH brute force is to jump onto one node and manually loop `ssh` against `localhost` with bad credentials. We predefined a user called `testuser` with password `testpassword` in the image context.

Start a `testuser` brute force sequence:
```bash
kubectl exec -it deployment/linux-endpoints -n endpoint-simulation -- bash

# (Once inside the container)
for i in {1..20}; do 
  sshpass -p "wrongpassword" ssh -o StrictHostKeyChecking=no testuser@localhost "echo hello"
done
```

> [!TIP]
> You can also try failed `sudo su` elevation commands as the `testuser`, which will generate classic `auth.log` privileges abuse alerting inside the Elastic Security platform!

### 2. Verify Data in Kibana

The Agent is securely polling the internal `/var/log/syslog` and `/var/log/auth.log` paths.
Simply launch your Dev Tools (or Discover app) in Kibana and query the data stream:

```json
GET logs-system.auth-*/_search
{
  "query": {
    "match": {
      "user.name": "testuser"
    }
  }
}
```

## Management and Configuration

If you'd like to scale out down to zero endpoints or up to 20 endpoints across your mock network natively, modify `replicaCount: 2` in `isolated/linux-endpoints/chart/values.yaml` and re-run your deploy script:

```bash
./isolated/linux-endpoints/deploy.sh
```

*(Note: The deploy script handles pushing the new pods. The agents inside those new pods will automatically retrieve their policies from Kibana instantly upon boot).*
