# Elastic MCP Server Setup Guide

This guide provides step-by-step instructions for setting up and configuring the Elastic Model Context Protocol (MCP) server to enable AI assistants (like Claude Desktop, Cursor, VS Code) to interact with your Elasticsearch cluster.

## Prerequisites

- Elasticsearch 9.2.1 cluster running
- Kibana 9.2.1 accessible
- kubectl access to your Kubernetes cluster
- curl or similar HTTP client

## Step 1: Port Forwarding

Ensure both Elasticsearch and Kibana are accessible from your host machine:

### Elasticsearch Port Forwarding
```bash
kubectl port-forward -n elastic-system svc/quickstart-es-http 9200:9200
```

### Kibana Port Forwarding
```bash
kubectl port-forward -n elastic-system svc/kibana-kb-http 5601:5601
```

**Note:** Keep both port forwarding commands running in separate terminals while using the MCP server.

## Step 2: Create API Key

Create an API key with appropriate privileges for MCP server access:

```bash
curl -X POST "https://localhost:9200/_security/api_key" \
  -H "Content-Type: application/json" \
  -u "elastic:${ELASTIC_PASSWORD}" \
  -k \
  -d '{
    "name": "elastic-mcp-api-key",
    "expiration": "30d",
    "role_descriptors": {
      "mcp-access": {
        "cluster": ["all"],
        "indices": [
          {
            "names": ["*"],
            "privileges": ["all"]
          }
        ],
        "applications": [
          {
            "application": "kibana-.kibana",
            "privileges": ["read_onechat", "space_read"],
            "resources": ["space:default"]
          }
        ]
      }
    }
  }'
```

**Response Example:**
```json
{
  "id": "your-api-key-id",
  "name": "elastic-mcp-api-key",
  "expiration": 1768472799458,
  "api_key": "your-generated-api-key",
  "encoded": "your-encoded-api-key"
}
```

## Step 3: Configure MCP Client

### Environment Variables
Set the following environment variables (replace with your actual values):

```bash
export KIBANA_URL="http://localhost:5601"
export API_KEY="${API_KEY}"
export ELASTIC_PASSWORD="${ELASTIC_PASSWORD}"
```

### MCP Server Configuration

Create or update your MCP client configuration file (typically `~/.config/claude/mcp.json` for Claude Desktop, or equivalent for other clients):

```json
{
  "mcpServers": {
    "elastic-agent-builder": {
      "command": "npx",
      "args": [
        "mcp-remote",
        "http://localhost:5601/api/agent_builder/mcp",
        "--header",
        "Authorization:ApiKey ${API_KEY}"
      ],
      "env": {
        "KIBANA_URL": "http://localhost:5601",
        "AUTH_HEADER": "ApiKey ${API_KEY}"
      }
    }
  }
}
```

### Alternative Configuration (Direct URL)

If your MCP client supports direct URL configuration:

```json
{
  "mcpServers": {
    "elastic-agent-builder": {
      "command": "npx",
      "args": [
        "mcp-remote",
        "${KIBANA_URL}/api/agent_builder/mcp",
        "--header",
        "Authorization:${AUTH_HEADER}"
      ],
      "env": {
        "KIBANA_URL": "http://localhost:5601",
        "AUTH_HEADER": "ApiKey ${API_KEY}"
      }
    }
  }
}
```

## Step 4: Test the Connection

1. Restart your MCP client (Claude Desktop, Cursor, VS Code, etc.)
2. The Elastic Agent Builder tools should now be available
3. Test by asking the AI assistant to perform Elasticsearch operations



## Security Considerations

- The API key has broad permissions for development/testing
- For production use, consider restricting privileges to specific indices
- Rotate API keys regularly
- Never commit API keys to version control

## Troubleshooting

### Connection Issues
- Ensure port forwarding is active for both ports 9200 and 5601
- Verify Elasticsearch and Kibana are running: `kubectl get pods -n elastic-system`
- Check API key is not expired

### Authentication Errors
- Verify the API key is correct
- Ensure the Authorization header format is `ApiKey {API_KEY}`
- Check Kibana URL is accessible

### MCP Client Issues
- Restart the MCP client after configuration changes
- Check client logs for connection errors
- Verify `npx mcp-remote` is available (`npm install -g mcp-remote`)

## MCP Server Endpoint

The MCP server is available at:
```
http://localhost:5601/api/agent_builder/mcp
```

For custom Kibana spaces:
```
http://localhost:5601/s/{SPACE_NAME}/api/agent_builder/mcp
```

## Available Tools

Once connected, the MCP server provides access to Elastic Agent Builder tools for:
- Index management
- Data querying
- Cluster monitoring
- Agent configuration
- Pipeline management
