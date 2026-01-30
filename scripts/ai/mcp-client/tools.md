# MCP Client Tools API Documentation

## Main repo 

- Code for frontend and backend at
```
https://github.com/getkub/simple-mcp-client
```

## API Endpoints

### Tools API
- **Path**: `/api/agent_builder/tools`
- **Purpose**: Manage and execute tools

### Agents API  
- **Path**: `/api/agent_builder/agents`
- **Purpose**: Manage AI agents

### Chat/Converse API
- **Path**: `/api/agent_builder/converse`
- **Purpose**: Interactive conversations with agents

Let's explore each API in more detail.

## Tools API Examples

### Create a Tool

```http
POST kbn://api/agent_builder/tools
```

```json
{
  "id": "neg_news_reports_with_pos",
  "type": "esql",
  "description": "Find accounts that have a position in a negative sentiment news or report in the specified timeframe.",
  "configuration": {
    "query": """
      FROM financial_news, financial_reports METADATA _index
      | WHERE coalesce(published_date, report_date) >= NOW() - TO_TIMEDURATION(?time_duration)
      | WHERE primary_symbol IS NOT NULL AND primary_symbol != "No_Symbol_Found"
      | WHERE sentiment == "negative"
      | RENAME primary_symbol AS symbol
      | LOOKUP JOIN financial_asset_details ON symbol
      | LOOKUP JOIN financial_holdings ON symbol
      | LOOKUP JOIN financial_accounts ON account_id
      | WHERE asset_name IS NOT NULL
      | EVAL position_current_value = quantity * current_price.price
      | KEEP
          article_id,
          report_id,
          title,
          published_date,
          report_date,
          sentiment,
          symbol,
          _index,
          asset_name,
          sector,
          account_holder_name,
          account_id,
          account_type,
          risk_profile,
          quantity,
          purchase_price,
          position_current_value
      | SORT coalesce(published_date, report_date) DESC, position_current_value DESC
      | LIMIT 500
    """,
    "params": {
      "time_duration": {
        "type": "keyword",
        "description": "The timeframe to search back. Format is \"X hours|minutes\" eg. \"7 hours\""
      }
    }
  },
  "tags": ["retrieval"]
}
```

### Execute a Tool

```http
POST kbn://api/agent_builder/tools/_execute
```

```json
{
  "tool_id": "news_and_report_lookup_with_symbol_detail",
  "tool_params": {
    "symbol": "DIA",
    "time_duration": "10000 hours"
  }
}
```

## Agents API Examples

### List All Agents

```http
GET kbn://api/agent_builder/agents
```

### Create an Agent

```http
POST kbn://api/agent_builder/agents
```

```json
{
  "id": "financial_news_agent",
  "name": "Financial News Agent",
  "description": "An agent focused on providing news and reports as they relate to financial positions.",
  "configuration": {
    "instructions": "You are a specialized AI assistant that provides financial news and reports for specific assets. Your only job is to use the available tools to find news and reports when a user asks about a financial symbol. Present the information clearly in Markdown format. Do not answer questions outside of this scope or perform any other tasks.",
    "tools": [
      {
        "tool_ids": [
          "esql_symbol_news_and_reports"
        ]
      }
    ]
  }
}
```

### Get Agent Details

```http
GET kbn://api/agent_builder/agents/financial_news_agent
```
