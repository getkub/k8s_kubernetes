# Mem0 self-hosted Helm chart

This chart deploys the Mem0 OSS REST API with PostgreSQL/pgvector in Kubernetes. It is intended to give n8n, Elastic, and other in-cluster agents a private long-term memory service.

This is the self-hosted/open-source Mem0 server, not the managed Mem0 Platform at `api.mem0.ai`. If you intended to use the managed platform, use its API key and hosted endpoint instead; Kubernetes deployment is unnecessary.

The chart follows Mem0's current self-hosted server contract:

- API image: `mem0/mem0-api-server`, listening on container port `8000`.
- Database: `pgvector/pgvector:pg17`, with a second `mem0_app` database created for authentication/configuration data.
- Authentication stays enabled by default. Programmatic callers use `X-API-Key`.
- The chart does not store credentials in Git. Provide an existing Kubernetes Secret or explicitly opt into chart-created secrets for local development.

The official Mem0 stack currently builds its dashboard from the `server/dashboard` source tree rather than publishing a clearly supported dashboard image. The chart therefore deploys the API/database core by default and has an opt-in dashboard deployment for an image built and published by the operator.

## Install

Create a namespace and a Secret. The Secret should contain `OPENAI_API_KEY`, `JWT_SECRET`, `POSTGRES_PASSWORD`, and optionally `ADMIN_API_KEY`.

```bash
kubectl create namespace mem0

kubectl create secret generic mem0-secrets \
  --namespace mem0 \
  --from-literal=OPENAI_API_KEY='replace-me' \
  --from-literal=JWT_SECRET="$(openssl rand -base64 48)" \
  --from-literal=POSTGRES_PASSWORD="$(openssl rand -base64 32)" \
  --from-literal=ADMIN_API_KEY="$(openssl rand -base64 32)"

helm upgrade --install mem0 ./isolated/mem0 \
  --namespace mem0 \
  --set secrets.existingSecret=mem0-secrets
```

The API service is available to in-cluster clients at:

```text
http://mem0-api.mem0.svc.cluster.local:8000
```

For local verification:

```bash
kubectl -n mem0 port-forward svc/mem0-api 8888:8000
curl -fsS http://localhost:8888/docs
```

## Verify memory operations

Mem0's self-hosted API uses `/memories` and `/search` without a `/v1` prefix.

```bash
export MEM0_API_KEY='the-admin-or-per-user-key'

curl -fsS -X POST http://localhost:8888/memories \
  -H "Content-Type: application/json" \
  -H "X-API-Key: ${MEM0_API_KEY}" \
  -d '{
    "messages": [{"role": "user", "content": "The SOC investigation workflow uses Elastic ES|QL alerts."}],
    "user_id": "soc-analyst"
  }'

curl -fsS -X POST http://localhost:8888/search \
  -H "Content-Type: application/json" \
  -H "X-API-Key: ${MEM0_API_KEY}" \
  -d '{"query":"What does the SOC workflow use?","user_id":"soc-analyst"}'
```

For new installations, prefer a per-user API key created from the Mem0 dashboard or the authenticated `/api-keys` endpoint. `ADMIN_API_KEY` is retained as a practical bootstrap/automation path; keep it long and private.

## n8n integration shape

Use two n8n HTTP Request nodes with a Header Auth credential that sends `X-API-Key`:

1. `POST http://mem0-api.mem0.svc.cluster.local:8000/memories` after an investigation, with `messages` containing the analyst/agent exchange and a stable `user_id` or `agent_id` such as `soc-analyst`.
2. `POST http://mem0-api.mem0.svc.cluster.local:8000/search` before an investigation, with the alert/rule question as `query` and the same identifier.

Keep the Mem0 API Service internal to the cluster when only n8n needs it. An external n8n instance should use the TLS-protected ingress hostname instead.

## Exposing the API outside the cluster

Set `ingress.enabled=true`, configure an ingress class/host, and provide TLS through the ingress controller. Do not expose this service over plain HTTP to an untrusted network. Keep the API private when only n8n needs it.

## Dashboard (optional)

Build `mem0/server/dashboard` from the official Mem0 repository, publish it to an operator-controlled registry, then enable it:

```bash
helm upgrade --install mem0 ./isolated/mem0 \
  --namespace mem0 \
  --set secrets.existingSecret=mem0-secrets \
  --set dashboard.enabled=true \
  --set dashboard.image.repository=registry.example/mem0-dashboard \
  --set dashboard.nextPublicApiUrl=http://localhost:8888
```

When the dashboard is enabled, `nextPublicApiUrl` must be a URL reachable by the browser, while the dashboard's server-side API URL is wired to the in-cluster API Service automatically.

## Configuration notes

- `api.defaultLlmModel` defaults to `gpt-5-mini` and `api.defaultEmbedderModel` to `text-embedding-3-small`.
- Set `api.telemetry=false` by default in this chart; change it only if anonymous installation telemetry is desired.
- Demo installs use ephemeral PostgreSQL storage by default, so rebuilding/recreating the release starts with empty memory. If a demo needs persistence across pod restarts, set `postgres.persistence.enabled=true`; the default PVC size is only `1Gi`. For production, use a managed PostgreSQL/pgvector service or an operator and adapt the chart before scaling the API.
- `AUTH_DISABLED=true` is intentionally not the default and should only be used for local development.

## References

- [Mem0 self-hosted setup](https://docs.mem0.ai/open-source/setup)
- [Mem0 REST API server](https://docs.mem0.ai/open-source/features/rest-api)
- [Mem0 server Docker Compose](https://github.com/mem0ai/mem0/blob/main/server/docker-compose.yaml)
