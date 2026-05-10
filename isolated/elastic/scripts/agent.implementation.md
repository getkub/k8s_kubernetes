# Link Simulation Linux Endpoints to Fleet Server

This document outlines the architecture for connecting the `linux-endpoints` deployment to the native ECK Fleet Server.

## Key Technical Requirements

### 1. SSL Hostname Matching
> [!IMPORTANT]
> The Fleet Server URL **must** use the short hostname: `https://fleet-server-agent-http.elastic-agent.svc:8220`.
> Using the full `.cluster.local` suffix will cause SSL handshake failures because the ECK-generated certificates only include the shorter service names in their Subject Alternative Names (SANs).

### 2. Fleet Output & TLS Trust
Since simulated agents are running in a separate namespace (`endpoint-simulation`), they may not trust the internal ECK CA by default. 
- The `fleet-default-output` is configured with `ssl.verification_mode: none` to allow internal data ingestion to Elasticsearch without certificate errors.

### 3. Automated Configuration
The `deploy-agent.sh` script handles the following programmatically to ensure idempotency:
1. **Fleet Server Hosts**: Configures the global Fleet settings via `/api/fleet/fleet_server_hosts`.
2. **Policy Management**: Creates `eck-fleet-server`, `eck-agent`, and `linux-endpoints-policy` if they don't exist.
3. **Token Generation**: Automatically retrieves or generates enrollment tokens for the policies.
4. **Endpoint Patching**: Dynamically updates the `linux-endpoints` deployment only if the `FLEET_URL` or `ENROLLMENT_TOKEN` has changed.

## Maintenance Commands

### Check Agent Status
```bash
# Check Fleet Server health
kubectl exec -n elastic-agent $(kubectl get pods -n elastic-agent -l agent.k8s.elastic.co/name=fleet-server -o name) -- elastic-agent status

# Check Elastic Agent health (DaemonSet)
kubectl exec -n elastic-agent $(kubectl get pods -n elastic-agent -l agent.k8s.elastic.co/name=elastic-agent -o name | head -n 1) -- elastic-agent status
```

### Force Policy Refresh
If agents show "Outdated policy", restarting the pods or running `deploy-agent.sh` again will trigger a check-in.

## Verification
- **Kibana Fleet UI**: Confirm all agents are "Healthy".
- **Logs**: Check `kubectl logs -n endpoint-simulation ...` for any "x509: certificate signed by unknown authority" errors.
