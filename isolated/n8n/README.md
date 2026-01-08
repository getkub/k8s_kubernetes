# N8N Kubernetes Setup

## Access N8N

N8N is deployed in the `n8n-system` namespace.

### Port Forwarding (http://localhost:5678)
Run this command in a terminal:
```bash
kubectl -n n8n-system port-forward svc/n8n-stack-n8n-stack 5678:80
```
Then access n8n at: **http://localhost:5678**

*✅ Currently active and working perfectly*

## Current Setup
- **Namespace**: n8n-system
- **Helm Release**: n8n-stack
- **Database**: SQLite (persistent storage enabled)
- **Cache/Queue**: Redis (separate service, configured via n8n credentials)
- **Service**: ClusterIP on port 80

## Useful Commands

### Check pod status
```bash
kubectl get pods -n n8n-system
```

### Check deployment status
```bash
kubectl get deployments -n n8n-system
```

### View logs
```bash
kubectl logs -f deployment/n8n-stack-n8n-stack -n n8n-system
```

### Check Redis status (when enabled)
```bash
kubectl get pods -n n8n-system -l app=n8n-stack-redis
kubectl logs -f deployment/n8n-stack-n8n-stack-redis -n n8n-system
```

### Test Redis connectivity
```bash
# Quick ping test
kubectl run redis-test --image=redis:8.2.3-alpine --rm -it --restart=Never -- redis-cli -h n8n-stack-n8n-stack-redis.n8n-system.svc.cluster.local ping

# Full test with data operations
kubectl run redis-test --image=redis:8.2.3-alpine --rm -it --restart=Never -- /bin/sh -c "redis-cli -h n8n-stack-n8n-stack-redis.n8n-system.svc.cluster.local set test 'working!' && redis-cli -h n8n-stack-n8n-stack-redis.n8n-system.svc.cluster.local get test"
```

### Upgrade n8n
After updating `values.yaml` (e.g., to change the n8n version or Redis settings), upgrade the deployment:
```bash
helm upgrade n8n-stack ./isolated/n8n -n n8n-system
```

### Redis Configuration
Redis runs as a separate service and is **disabled by default**. To enable and use Redis for caching/queueing in n8n:

1. **Enable Redis** in `values.yaml`:
   ```yaml
   redis:
     enabled: true
   ```

2. **Upgrade the deployment**:
   ```bash
   helm upgrade n8n-stack ./isolated/n8n -n n8n-system
   ```

3. **Access n8n UI** at http://localhost:5678
4. **Go to Settings > External Data Storage**
5. **Configure Redis connection**:
   - Host: `n8n-stack-n8n-stack-redis.n8n-system.svc.cluster.local`
   - Port: `6379`
   - Password: (leave empty if auth disabled, or set password if enabled)

### Redis Authentication (Optional)
To enable Redis authentication, update `values.yaml`:
```yaml
redis:
  auth:
    enabled: true
    password: "your-secure-password-here"
```
Then upgrade the deployment. Redis will require authentication for all connections.

## kubectl Alias
The alias `k=kubectl` has been added to `~/.zshrc` for convenience.

## n8n-mcp Configuration

n8n-mcp is configured for use with Cline. To set it up:

1. **Set the API key environment variable:**
   ```bash
   export N8N_API_KEY="your-api-key-here"
   ```

2. **Copy the MCP configuration to Cline:**
   ```bash
   cp isolated/n8n/n8n-mcp-config.json ~/Library/Application\ Support/Code/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json
   ```

3. **Restart VS Code/Cline** to pick up the new MCP configuration.

The configuration uses environment variables so the API key is never committed to the repository.
