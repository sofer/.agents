---
name: "notion-query"
description: "Search and retrieve content from a Notion workspace"
type: atomic
input: "A search query (string) or a page ID/URL (string), with optional scope and filters"
output: "Search results (list of pages with titles, URLs, snippets) or full page content in Notion-flavoured Markdown"
---

# Notion query

## Purpose

Search for and retrieve content from the user's Notion workspace. This skill provides read-only access to Notion via two operations: searching by query and fetching a specific page by ID. It wraps the Notion MCP server tools to give other skills a consistent interface for accessing business documentation.

## Prerequisites

This skill requires the Notion MCP server to be available. The following MCP tools must be accessible:

- `mcp__claude_ai_Notion__notion-search`
- `mcp__claude_ai_Notion__notion-fetch`

If either tool is unavailable, stop and report: "The Notion MCP server is unavailable. Ensure the Notion MCP integration is configured and running."

## Instructions

Determine which operation to perform based on the input:

### If a page ID or URL is provided (fetch mode)

1. Call `mcp__claude_ai_Notion__notion-fetch` with the page ID or URL as the `id` parameter.
   - Accepts full Notion URLs (e.g. `https://notion.so/workspace/Page-Title-abc123`), Notion Sites URLs (e.g. `https://myspace.notion.site/Page-Title-abc123`), raw UUIDs (with or without dashes), and data source URLs (e.g. `collection://...`).
2. Return the full page content as received from the tool. This will be in Notion-flavoured Markdown for pages, or schema and data source information for databases.

### If a search query is provided (search mode)

1. Call `mcp__claude_ai_Notion__notion-search` with the following parameters:
   - `query`: the search query string (required)
   - `query_type`: set to `"internal"` for content search (this is the default and most common use)
   - `page_url`: if a scope was provided and it is a page URL or ID, pass it here to restrict search to that page and its children
   - `data_source_url`: if a scope was provided and it is a data source URL (starts with `collection://`), pass it here to restrict search to that data source
   - `filters`: if date range or creator filters were provided, pass them as an object with `created_date_range` (containing `start_date` and/or `end_date` in ISO 8601 format) and/or `created_by_user_ids` (list of user ID strings)
2. Return the search results as received from the tool.
3. If the caller needs the full content of a specific result, they should invoke this skill again with that page's ID or URL.

### If both a page ID and a query are provided

Page ID takes precedence. Follow the fetch mode instructions above and ignore the query.

## Error handling

- If neither a query nor a page ID is provided, stop and report: "No query or page ID provided. Provide either a search query or a Notion page ID/URL."
- If the MCP tools are unavailable, stop and report: "The Notion MCP server is unavailable. Ensure the Notion MCP integration is configured and running."
- If a search returns no results, report that no results were found for the given query. Suggest trying broader or different search terms.
- If a page fetch fails (page not found or inaccessible), report the error and include the ID/URL that was tried.

## Output format

### Search results

The output from a search is a list of matching pages as returned by the Notion MCP server. Each result typically includes:
- Page title
- Page URL
- Content snippet showing the match

Present the results clearly so the calling skill can identify which page(s) are relevant.

### Page content

The output from a fetch is the full page content in Notion-flavoured Markdown. This includes headings, text, lists, tables, and any other content blocks on the page. For databases, the output includes the schema and data source information.

Return the content as-is. Do not summarise or truncate. The consuming skill decides what to extract.
