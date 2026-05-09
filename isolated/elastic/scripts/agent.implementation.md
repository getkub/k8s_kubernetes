# Link Simulation Linux Endpoints to Fleet Server

We need to properly connect your `linux-endpoints` deployment in the `endpoint-simulation` namespace to the new native ECK Fleet Server. Currently, they are using old environment variables (`FLEET_URL` and `ENROLLMENT_TOKEN`) that point to a non-existent setup.

## User Review Required

> [!IMPORTANT]
> The ECK Operator is currently struggling to automatically generate the Agent policies inside Kibana due to transient authentication timeouts when communicating with Kibana. 
> To bypass this and guarantee the simulated endpoints enroll successfully, I propose making `deploy-agent.sh` handle the policy creation and token generation via the Kibana API, similar to how your old `create-secrets.sh` worked.

## Proposed Changes

### `isolated/elastic/scripts/deploy-agent.sh`

I will update this script to:
1. Extract the `elastic` user password securely.
2. Wait for Kibana to be ready and available.
3. Use the Kibana API to programmatically create the Fleet Server policy (`eck-fleet-server`) to unblock the ECK Operator.
4. Use the Kibana API to create a dedicated agent policy for your simulated endpoints (e.g., `linux-endpoints-policy`).
5. Generate an enrollment token for that specific policy.
6. Programmatically patch the `linux-endpoints` deployment in the `endpoint-simulation` namespace to inject the correct `FLEET_URL` and `ENROLLMENT_TOKEN`.

#### [MODIFY] `isolated/elastic/scripts/deploy-agent.sh`
- Add Kibana API calls for policy and token generation.
- Add `kubectl set env` command to update the `linux-endpoints` deployment.

## Verification Plan

### Automated Tests
- Run `./scripts/deploy-agent.sh` and verify that both the `fleet-server` and `elastic-agent` pods transition to `Running` state.
- Check `kubectl get pods -n endpoint-simulation` to ensure the simulated endpoints successfully restart with the new injected environment variables.

### Manual Verification
- Check the Kibana Fleet UI to confirm that the `linux-endpoints` agents appear as "Healthy" and are successfully enrolled under the correct policy.
