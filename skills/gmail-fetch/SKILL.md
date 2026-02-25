---
name: "gmail-fetch"
description: "Fetch recent emails from Gmail with sender, subject, body, and thread context"
type: atomic
input: "Optional filters: query (Gmail search syntax, default 'is:unread'), max_results (integer, default 20), include_threads (boolean, default true)"
output: "List of emails with id, thread_id, from, to, subject, body, date, labels, and thread context"
---

# Gmail fetch

## Purpose

Fetch emails from Gmail so that other skills (particularly the email drafter twin) can work with inbox data. This skill is read-only; it never modifies, sends, or deletes emails.

## Prerequisites

This skill uses the Gmail API via existing OAuth credentials at `~/code/airmail/`. The following files must exist:

- `~/code/airmail/client_secret.json` — Google OAuth client credentials
- `~/code/airmail/gmail_token.json` — OAuth token (auto-refreshes)

## Instructions

### 1. Authenticate with Gmail

Load the OAuth credentials and build a Gmail API client:

```python
from google.oauth2.credentials import Credentials
from google.auth.transport.requests import Request
from googleapiclient.discovery import build

TOKEN_FILE = os.path.expanduser("~/code/airmail/gmail_token.json")
CLIENT_SECRET = os.path.expanduser("~/code/airmail/client_secret.json")

creds = Credentials.from_authorized_user_file(TOKEN_FILE)
if creds.expired and creds.refresh_token:
    creds.refresh(Request())
    with open(TOKEN_FILE, "w") as f:
        f.write(creds.to_json())

service = build("gmail", "v1", credentials=creds)
```

If the token file is missing, stop and report:
> "Gmail token not found at ~/code/airmail/gmail_token.json. Run the OAuth flow in the airmail project first."

If authentication fails after refresh, stop and report:
> "Gmail authentication failed. The token may be expired or revoked. Re-authenticate in ~/code/airmail/."

### 2. Parse the input parameters

Accept the following optional parameters. Apply defaults where not provided:

| Parameter | Default | Description |
|---|---|---|
| `query` | `is:unread` | Gmail search query (same syntax as the Gmail search bar) |
| `max_results` | `20` | Maximum number of emails to return |
| `include_threads` | `true` | Whether to fetch prior messages in each thread |

### 3. Fetch emails

1. List messages:
   ```python
   results = service.users().messages().list(
       userId="me", q=query, maxResults=max_results
   ).execute()
   messages = results.get("messages", [])
   ```

2. For each message ID returned, fetch full details:
   ```python
   msg = service.users().messages().get(
       userId="me", id=msg_id, format="full"
   ).execute()
   ```

3. If `include_threads` is true, fetch the thread:
   ```python
   thread = service.users().threads().get(
       userId="me", id=thread_id, format="full"
   ).execute()
   ```

### 4. Normalise the results

For each email, extract and normalise:

- **id**: Gmail message ID
- **thread_id**: Gmail thread ID
- **from**: Sender name and email (from the `From` header)
- **to**: Recipient addresses (from the `To` header)
- **cc**: CC addresses (from the `Cc` header, if present)
- **subject**: Subject line (from the `Subject` header)
- **body**: Email body as plain text. If the email has a `text/plain` part, use it. If it only has `text/html`, strip the HTML tags to produce plain text. Truncate to 10,000 characters if longer, appending "[truncated]".
- **date**: Date sent (from the `Date` header), formatted as ISO 8601
- **labels**: Gmail labels (e.g. INBOX, UNREAD, IMPORTANT)
- **snippet**: Short preview of the body (first 200 characters)

If `include_threads` is true, for each thread include up to 10 of the most recent prior messages (excluding the current message) with:
- **id**: Message ID
- **from**: Sender
- **date**: Date sent (ISO 8601)
- **body**: Plain text body (truncated to 5,000 characters if longer)

### 5. Return the output

Present the results as a structured list of emails ordered by date (most recent first), along with:

- **result_count**: Number of emails returned
- **query_used**: The Gmail query that was executed

## Error handling

- **Token file missing**: Stop and report: "Gmail token not found at ~/code/airmail/gmail_token.json"
- **Authentication failure** (401 or 403): Stop and report: "Gmail authentication failed. Re-authenticate in ~/code/airmail/."
- **Rate limit exceeded** (429): Stop and report: "Gmail API rate limit exceeded. Wait a few minutes before retrying."
- **No results**: Not an error. Return an empty list with result_count of 0.

## Output format

```yaml
result_count: 3
query_used: "is:unread"
emails:
  - id: "msg_abc123"
    thread_id: "thread_xyz789"
    from: "Alice Smith <alice@example.com>"
    to: ["user@example.com"]
    cc: []
    subject: "Re: Partnership proposal"
    body: "Hi, thanks for sending over the details..."
    date: "2026-02-25T09:30:00Z"
    labels: ["INBOX", "UNREAD"]
    snippet: "Hi, thanks for sending over the details..."
    thread_messages:
      - id: "msg_prev456"
        from: "user@example.com"
        date: "2026-02-24T16:00:00Z"
        body: "Hi Alice, please find attached..."
```
