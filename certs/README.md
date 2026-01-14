# Local Development Certificate Authority

## Setup

```bash
cd certs/scripts

# Generate root CA
./generate-ca.sh

# Generate server certificates
./generate-server-cert.sh

# Add CA to Node.js trust store (enables n8n to trust certificates)
./add-to-nodejs-trust.sh

# Generate Splunk certificates and app (optional)
./generate-splunk-cert.sh
./create-splunk-app.sh

# Generate Kubernetes secrets (optional)
./generate-k8s-secret.sh
```

## Verification

### Certificate Validation
```bash
# Verify server certificate chain
openssl verify -CAfile certs/ca/ca.crt certs/server/server.crt

# Verify Splunk certificate chain
openssl verify -CAfile certs/ca/ca.crt certs/splunk/splunk.crt
```

### Node.js Trust Test
```bash
# Test Node.js trusts our CA
export NODE_EXTRA_CA_CERTS="$HOME/.node/extra-ca-certs.crt"
node -e "require('https').get('https://localhost:8443', {rejectUnauthorized: true}, () => console.log('✅ Trust works')).on('error', (e) => console.log('❌ Trust failed:', e.code))"
```

### Kubernetes
```bash
# Apply certificates to cluster
kubectl apply -f certs/k8s-tls-secret-populated.yaml

# Verify secret exists
kubectl get secrets -n n8n-system local-dev-tls
```

## Splunk Configuration

The `create-splunk-app.sh` script creates a Splunk app called `my_splunk_certs` with the following structure:

**macOS** (`/Applications/Splunk/etc/apps/my_splunk_certs/`):
**Linux** (`/opt/splunk/etc/apps/my_splunk_certs/`):

```
my_splunk_certs/
├── default/
│   └── app.conf          # App metadata (read-only defaults)
├── local/
│   ├── mcp.conf          # SSL verification for MCP server
│   └── certs/            # Certificate files
│       ├── splunk.crt
│       ├── splunk.key
│       └── ca.crt
└── metadata/
    └── local.meta        # Permissions
```

**To activate:**
```bash
# macOS
/Applications/Splunk/bin/splunk restart

# Linux
/opt/splunk/bin/splunk restart
```

The app includes `mcp.conf` with `ssl_verify` pointing to the CA certificate for MCP server SSL verification. SplunkWeb continues to use default SSL settings.

## n8n Configuration

Update `isolated/n8n/values.yaml`:
```yaml
tls:
  enabled: true
  secretName: local-dev-tls

ingress:
  enabled: true
  hosts:
    - host: n8n.localhost
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: local-dev-tls
      hosts:
        - n8n.localhost
```

## Certificate Validity

- **CA**: 10 years
- **Server certificates**: 1 year
- **Renew before expiration**: Run generation scripts again
