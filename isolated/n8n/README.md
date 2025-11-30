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
- **Version**: 1.121.3 (latest)
- **Namespace**: n8n-system
- **Helm Release**: n8n-stack
- **Database**: SQLite (persistent storage enabled)
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

### Upgrade n8n
```bash
helm upgrade n8n-stack ./isolated/n8n -n n8n-system
```

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
