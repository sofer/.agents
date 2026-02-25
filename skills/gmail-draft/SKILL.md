---
name: "gmail-draft"
description: "Create a draft email in Gmail from provided email data"
type: atomic
input: "Email data: to, subject, body (required); cc, bcc, thread_id, in_reply_to, references (optional)"
output: "Confirmation with draft ID, thread ID (if threaded), and a human-readable summary"
---

# Gmail draft

## Purpose

Create a draft email in the user's Gmail account. The draft is saved for human review — this skill never sends emails. It accepts already-composed email content and passes it through to the Gmail API.

## Prerequisites

This skill uses the existing Gmail draft script and OAuth credentials at `~/code/airmail/`. The following files must exist:

- `~/code/airmail/gmail_draft.py` — the draft creation script
- `~/code/airmail/client_secret.json` — Google OAuth client credentials
- `~/code/airmail/gmail_token.json` — OAuth token (auto-refreshes)
- `~/code/airmail/email-signature.html` — email signature (appended automatically)

## Instructions

### 1. Validate required fields

Check that the following fields are present in the input:

- **to** — one or more recipient email addresses
- **subject** — the email subject line
- **body** — the email body text

If any of these are missing or empty, stop and report which field(s) are missing. Do not proceed.

### 2. Create the draft

Use the existing `gmail_draft.py` script in `~/code/airmail/`:

**For a reply in an existing thread:**
```bash
python3 ~/code/airmail/gmail_draft.py "<thread_id>" "<to>" "<body>"
```

**For a new conversation:**
```bash
python3 ~/code/airmail/gmail_draft.py new "<to>" "<subject>" "<body>"
```

The script:
- Handles OAuth authentication (token refresh if needed)
- Appends the email signature from `email-signature.html`
- Creates the draft via the Gmail API
- Returns the draft ID on success

### 3. Handle the response

**On success:**
Report the result with:
- **status**: "created"
- **draft_id**: the draft ID returned by the script
- **thread_id**: the thread ID, if this was a threaded reply
- **summary**: a human-readable line, e.g. "Draft created: {subject} to {to}"

**On error:**
Report the result with:
- **status**: "error"
- **error**: the error message from the script

Do not attempt to retry or work around errors. Report them as-is.

### Alternative: direct API usage

If the script is unavailable or a more complex draft is needed (e.g. with CC/BCC), use the Gmail API directly:

```python
import os
from google.oauth2.credentials import Credentials
from google.auth.transport.requests import Request
from googleapiclient.discovery import build
from email.mime.text import MIMEText
import base64

TOKEN_FILE = os.path.expanduser("~/code/airmail/gmail_token.json")

creds = Credentials.from_authorized_user_file(TOKEN_FILE)
if creds.expired and creds.refresh_token:
    creds.refresh(Request())
    with open(TOKEN_FILE, "w") as f:
        f.write(creds.to_json())

service = build("gmail", "v1", credentials=creds)

# Build the message
message = MIMEText(body)
message["to"] = to
message["subject"] = subject
if cc:
    message["cc"] = cc
if in_reply_to:
    message["In-Reply-To"] = in_reply_to
    message["References"] = references or in_reply_to

raw = base64.urlsafe_b64encode(message.as_bytes()).decode()

draft_body = {"message": {"raw": raw}}
if thread_id:
    draft_body["message"]["threadId"] = thread_id

draft = service.users().drafts().create(userId="me", body=draft_body).execute()
```

## Error handling

- If `to`, `subject`, or `body` is missing, stop and report which required field(s) are absent
- If the script or token file is missing, stop and report the expected path
- If authentication fails, report the auth error and suggest re-authenticating in `~/code/airmail/`
- If the API returns an error, report it verbatim
- If `thread_id` is invalid, do not fall back to creating an unthreaded draft — report the error

## Output format

On success:
```
status: created
draft_id: {id from API}
thread_id: {thread id, if threaded}
summary: Draft created: {subject} → {to}
```

On error:
```
status: error
error: {error description}
```
