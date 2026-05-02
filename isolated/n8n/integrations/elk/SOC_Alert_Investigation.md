# Elastic Security SOC Alert Investigation Workflow

This document records the design, implementation plan, and context for the SOC Alert Investigation workflow built in n8n.

## Overview

The workflow automatically polls Elastic Security for open SOC alerts and creates a corresponding Incident Case in Kibana Case Management. It achieves this by communicating directly with the Kibana internal APIs rather than using standard Elasticsearch CRUD operations, ensuring that the internal states of alerts and cases are managed correctly.

## Architecture & Integration Strategy

### n8n Model Context Protocol (MCP) Integration
Elastic Agent Builder exposes an MCP server endpoint that allows n8n AI agents to natively access Elasticsearch tools. 
- **Endpoint:** `{KIBANA_URL}/api/agent_builder/mcp`
- **Transport:** Standard input/output (stdio) bridged via the `npx mcp-remote` package.
- **n8n Configuration:**
  - **Command:** `npx`
  - **Args:** `mcp-remote`, `https://your-kibana-url/api/agent_builder/mcp`, `--header`, `Authorization:ApiKey YOUR_API_KEY`
- **Required API Key Privileges:** To use the Elastic MCP server, the API key must have Kibana application privileges specifically for `feature_agentBuilder.read` and `feature_actions.read`.

### Workflow Structure

The workflow consists of four sequential nodes:

#### 1. Schedule Trigger
- **Type:** `n8n-nodes-base.scheduleTrigger`
- **Purpose:** Triggers the workflow at regular intervals (e.g., every 15 minutes).

#### 2. Fetch Alerts (HTTP Request)
- **Type:** `n8n-nodes-base.httpRequest`
- **Purpose:** Authenticates with local Elasticsearch/Kibana using an API key. It queries the Elastic Security Detection Engine API (`/api/detection_engine/signals/search`) to retrieve recent alerts with the status "open".
- **Design Note:** We use the HTTP Request node instead of the native n8n Elasticsearch node because the native node is designed for basic document CRUD. Elastic Security alerts and cases are specialized constructs best managed via Kibana's official APIs.

#### 3. Parse Alerts (Code Node)
- **Type:** `n8n-nodes-base.code`
- **Purpose:** Parses the JSON response from Elastic Security. It filters out noise, counts the signals, and formats the alert data (including rule names and severities) into a human-readable investigation summary.
- **Future Enhancement:** This code node can be replaced or augmented with an AI Agent node (e.g., OpenAI or Anthropic) to intelligently summarize alerts, extract indicators of compromise (IoCs), and determine priority.

#### 4. Create Case (HTTP Request)
- **Type:** `n8n-nodes-base.httpRequest`
- **Purpose:** Calls the Kibana Case Management API (`/api/cases`) to automatically create an incident response case. It attaches the formatted analysis and tags the case as automated by n8n.

## Deployment Details

- **n8n Instance:** Kubernetes cluster (`n8n-system` namespace)
- **Elasticsearch Instance:** Kubernetes cluster (`elastic-system` namespace)
- **Status:** The initial workflow template was generated programmatically into n8n and set to an inactive state. To use it, the placeholders for `ApiKey YOUR_API_KEY_HERE` must be updated with a valid API key possessing the necessary Kibana application privileges.

## Future Use
This pattern can be extended to:
1. Trigger automatic Slack/Teams notifications when high-severity cases are created.
2. Use the Elastic MCP Server integration so n8n AI Agents can dynamically query logs during the investigation phase before the case is created.
3. Automatically resolve alerts in Elastic if the AI Agent determines they are false positives based on contextual data.
