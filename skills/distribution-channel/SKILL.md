---
name: "distribution-channel"
description: "Identify and evaluate distribution channels for the ML engineer apprenticeship"
type: atomic
input: "Apprenticeship details from business context config, optional focus area or constraint"
output: "Ranked channel recommendations with rationale, estimated reach, effort, and cost"
---

# Distribution channel

## Purpose

Evaluate and rank distribution channels for the ML engineer apprenticeship. This skill combines business context configuration with optional data from Notion and Postgres to produce informed, prioritised channel recommendations suited to a sole operator.

## Config loading

Before executing, read the required configuration:

1. Read `~/.agents/config/business-context/offerings.yaml` for apprenticeship details (name, description, audience, USPs, pricing)
2. Read `~/.agents/config/business-context/company.yaml` for company context (optional but useful for positioning)
3. If `offerings.yaml` is missing, stop and report: "Required config not found: ~/.agents/config/business-context/offerings.yaml. This file must contain at least one offering with details about the ML apprenticeship."
4. If `offerings.yaml` exists but all offering fields are empty, stop and report: "The offerings config at ~/.agents/config/business-context/offerings.yaml needs to be populated with actual apprenticeship details (name, audience, USPs)."

## Instructions

### 1. Extract the ML apprenticeship offering

From the loaded `offerings.yaml`, identify the ML engineer apprenticeship offering. If there are multiple offerings, select the one that most clearly relates to ML engineering or apprenticeships. Note the following details for use in evaluation:

- **Name**: the offering name
- **Audience**: who this is for (e.g. career changers, junior developers, ML practitioners)
- **USPs**: what makes this offering distinctive
- **Other details**: pricing, format, duration, or anything else that affects channel selection

### 2. Search Notion for existing distribution and marketing content

If Notion is available and not explicitly excluded, search for existing documentation that could inform channel selection.

Use `mcp__claude_ai_Notion__notion-search` with the following queries (run each separately):

1. `"distribution strategy"` or `"distribution channels"`
2. `"marketing"` combined with the offering name
3. `"campaign results"` or `"signup sources"`

For each search:
- Review the results and identify the most relevant pages (up to 3-5 total across all searches)
- Use `mcp__claude_ai_Notion__notion-fetch` to retrieve the full content of each relevant page
- Extract insights about: channels that have been tried, what worked, what did not, audience observations

If the Notion MCP server is unavailable (tools `mcp__claude_ai_Notion__notion-search` or `mcp__claude_ai_Notion__notion-fetch` are not accessible), note this and proceed without Notion data. Do not treat this as a fatal error.

If searches return no relevant results, note this and proceed.

### 3. Query Postgres for historical signup data

If Postgres is available and not explicitly excluded, query for historical signup and channel performance data.

**Check credentials**: Verify that database connection credentials are available from environment variables (`DATABASE_URL`, or the combination of `PGHOST`, `PGDATABASE`, `PGUSER`, `PGPASSWORD`). If credentials are not set, note that Postgres is unavailable and proceed to step 4.

**Inspect schema**: Run the following query via `psql` (or a Postgres MCP server if available):

```sql
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
ORDER BY table_schema, table_name;
```

Look for tables related to signups, leads, campaigns, or channel tracking. If relevant tables exist, inspect their columns:

```sql
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = '{table}'
ORDER BY ordinal_position;
```

**Query signup data**: If tables with signup or channel data exist, query for:

- Total signups by channel/source (if channel attribution exists)
- Signup trends over time
- Conversion rates by channel (if conversion data exists)

Apply a `LIMIT 100` to all queries. Use `--csv --no-psqlrc -v ON_ERROR_STOP=1` flags with psql.

**Read-only only**: Execute only SELECT queries. Never execute INSERT, UPDATE, DELETE, DROP, ALTER, TRUNCATE, CREATE, or any other write operation.

If Postgres is unreachable, credentials are missing, or the schema contains no relevant tables, note this and proceed to step 4. Do not treat this as a fatal error.

### 4. Evaluate and rank distribution channels

Using the data gathered from the previous steps, evaluate distribution channels across these dimensions:

| Dimension | Description | Weight |
|---|---|---|
| **Audience fit** | How well does this channel reach the target audience? | High |
| **Effort** | How much time does this require from a sole operator? | High (lower is better) |
| **Estimated reach** | How many potential signups could this channel generate? | Medium |
| **Cost** | What is the financial outlay? | Medium |
| **Historical performance** | What does past data say about this channel? | High (when available) |

For each channel, produce:

- **Rank**: position in the priority order (1 = highest)
- **Channel name**: the distribution channel
- **Rationale**: why this channel is recommended for this specific offering and audience
- **Estimated reach**: qualitative or quantitative estimate
- **Effort**: what is required from the operator
- **Cost**: financial estimate
- **Historical performance** (if data was available): what the data shows

When ranking:
- Prioritise channels where historical data shows strong performance
- For channels without historical data, weight audience fit and effort most heavily
- A sole operator has limited time, so favour high-impact, low-effort channels
- If a focus constraint was provided (e.g. "low-cost only", "LinkedIn focus"), apply it to filter or re-weight the ranking

Aim for 5-10 channel recommendations. Include a mix of organic, paid, and community-based channels where appropriate for the audience.

### 5. Compile the output

Present the results in the format described in the output format section below.

## Error handling

- If `~/.agents/config/business-context/offerings.yaml` is missing or empty, stop and report the expected path and what it should contain
- If the Notion MCP server is unavailable, note this in `data_sources_used` and proceed without Notion data
- If Postgres credentials are missing or the database is unreachable, note this in `data_sources_used` and proceed without historical data
- If Postgres has signup data but no channel/source attribution, note this and suggest adding channel tracking for future analysis
- If all optional data sources are unavailable, proceed with config-only baseline recommendations and clearly state that recommendations would improve with historical data

## Output format

Return the following structured output:

### Data sources used

List every source that informed the recommendations:
- Config files read (always includes `offerings.yaml`)
- Notion pages consulted (by title)
- Postgres tables queried (by name)
- Note any sources that were unavailable

### Constraints applied

If a focus constraint was provided, state it here. Otherwise omit this section.

### Channel recommendations

Present as a ranked list. For each channel:

```
**Rank N: Channel name**
- Rationale: Why this channel suits the ML apprenticeship audience
- Estimated reach: Qualitative or quantitative estimate
- Effort: What the operator needs to do and how much time it takes
- Cost: Financial estimate
- Historical performance: What the data shows (or "No historical data available")
```

### Summary

A brief (2-3 sentence) summary of the overall recommendation: which channels to prioritise first and why, given the operator's constraints.
