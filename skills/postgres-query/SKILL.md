---
name: "postgres-query"
description: "Query a Postgres database (read-only) and return structured results"
type: atomic
input: "A natural-language description of the data needed, or an explicit SQL SELECT statement"
output: "Query results as rows and columns, plus the SQL that was executed"
---

# Postgres query

## Purpose

Execute read-only queries against a Postgres database and return structured results. This skill enables other skills to access business data stored in Postgres (e.g. signup metrics, campaign performance, user data).

This skill is **read-only by default**. It refuses to execute any statement that would modify data.

## Instructions

### 1. Validate credentials

Check that database connection credentials are available from environment variables. Two formats are supported:

- **Connection URI**: `DATABASE_URL` (e.g. `postgresql://user:pass@host:5432/dbname`). If set, this takes precedence.
- **Individual variables**: `PGHOST`, `PGDATABASE`, `PGUSER`, `PGPASSWORD` (all required), plus `PGPORT` (optional, defaults to 5432).

If neither `DATABASE_URL` nor the required individual variables are set, stop and report:

> Postgres credentials not configured. Set the following environment variables: PGHOST, PGDATABASE, PGUSER, PGPASSWORD (or DATABASE_URL as a connection URI).

Never hardcode credentials. Never log or output credential values.

### 2. Determine the query

If the input is an **explicit SQL statement** (starts with SELECT, WITH, or EXPLAIN), use it directly. Proceed to step 3.

If the input is a **natural-language description**, inspect the database schema first:

1. List available tables:
   ```sql
   SELECT table_schema, table_name
   FROM information_schema.tables
   WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
   ORDER BY table_schema, table_name;
   ```

2. For tables that appear relevant to the request, inspect their columns:
   ```sql
   SELECT column_name, data_type, is_nullable
   FROM information_schema.columns
   WHERE table_name = '{table}'
   ORDER BY ordinal_position;
   ```

3. Formulate an appropriate SELECT query based on the schema and the natural-language request.

4. Apply a default `LIMIT 100` unless the caller specified a different limit or the query already contains a LIMIT clause.

### 3. Read-only guard

Before executing any SQL, verify the statement is read-only. **This check is mandatory and cannot be skipped.**

**Refuse the query if any of the following are true:**
- The statement (ignoring leading whitespace and comments) does not begin with `SELECT`, `WITH`, or `EXPLAIN`
- The statement contains any of these SQL commands: `INSERT`, `UPDATE`, `DELETE`, `DROP`, `ALTER`, `TRUNCATE`, `CREATE`, `GRANT`, `REVOKE`
- The statement contains `COPY ... FROM`
- The statement contains multiple statements separated by semicolons (excluding a single trailing semicolon)

**Important nuance**: Check for these as SQL commands, not merely as substrings. A column named `update_count` or a WHERE clause like `WHERE deleted = false` should not trigger a rejection. Analyse the statement structure. When in doubt, err on the side of caution and refuse.

If the query fails the read-only check, stop and report:

> This skill is read-only. The query contains a write operation ({operation}). Only SELECT queries are permitted.

### 4. Execute the query

Use one of the following methods, in order of preference:

**Option A: Postgres MCP server** (preferred if available)

If a Postgres MCP server is configured and accessible, use it to execute the query. This provides structured input/output.

**Option B: psql command line** (fallback)

Execute the query using `psql`:

```bash
psql -c "{query}" --csv --no-psqlrc -v ON_ERROR_STOP=1
```

- `--csv` produces machine-readable CSV output
- `--no-psqlrc` prevents user configuration from altering output format
- `-v ON_ERROR_STOP=1` stops on errors

If `DATABASE_URL` is set, pass it as the connection parameter. Otherwise, `psql` reads `PGHOST`, `PGPORT`, `PGDATABASE`, `PGUSER`, and `PGPASSWORD` from the environment automatically.

### 5. Return results

Present the results as structured data:

- **rows**: The query result rows
- **row_count**: Number of rows returned
- **query_executed**: The exact SQL that was run (for transparency and debugging)
- **truncated**: Whether the result was capped by the row limit

If the query returned no rows, return an empty result set (rows: [], row_count: 0). This is not an error.

## Error handling

- **Missing credentials**: Stop and report which environment variables are needed (see step 1)
- **Connection failure**: Report the connection error, including host and port. Never include the password in error messages.
- **Read-only violation**: Refuse the query and explain why (see step 3)
- **Query execution error** (bad SQL, missing table, permission denied): Report the error from psql or the MCP server, including the SQL that was attempted
- **Empty result**: Not an error. Return the empty result set normally.

## Output format

Return the following to the invoking context:

```
query_executed: <the SQL that was run>
row_count: <number of rows>
truncated: <true if result was limited>

<results as a formatted table or structured data>
```

When used as a step in a composite skill, the labelled output contains the full result set for subsequent steps to use.
