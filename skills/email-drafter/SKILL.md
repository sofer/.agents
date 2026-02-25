---
name: "email-drafter"
description: "Fetch unread emails, triage them, draft replies in the user's voice, and save as Gmail drafts for human review"
type: composite
depends_on:
  - gmail-fetch
  - notion-query
  - email-voice-draft
  - gmail-draft
---

# Email drafter

## Purpose

Process the user's unread emails into draft replies written in their voice. The twin fetches emails, filters out those that do not need a response, drafts replies using the user's voice profile and business knowledge (including Notion), and saves each draft to Gmail. Drafts are never sent -- the user reviews and sends them manually.

## Config loading

Before starting the steps below:
1. Read `~/.agents/config/voice-profile.yaml` for voice and tone rules
2. Read all `.yaml` files in `~/.agents/config/business-context/` for domain knowledge
3. If any required config is missing, stop and report the expected path

## Steps

### Step 1: Fetch unread emails
**Skill**: `gmail-fetch`
**Input**: Query `is:unread` (or a user-provided query), `max_results` 20 (or user-provided), `include_threads` true
**Output** → `emails`

Read and follow the instructions in `~/.agents/skills/gmail-fetch/SKILL.md`.
Fetch unread emails with thread context. If no emails are returned, report that there is nothing to process and stop (this is not an error).

### Step 2: Triage emails
**Skill**: none (inline judgement)
**Input**: `emails` from step 1
**Output** → `actionable_emails`

Review each email in `emails` and decide whether it needs a reply. Split the list into two groups:

**Skip** (no draft needed):
- Newsletters and mailing lists (look for List-Unsubscribe headers, noreply@ or no-reply@ senders, marketing/bulk labels)
- Automated notifications from services (e.g. GitHub, Stripe, calendar systems, monitoring alerts)
- Calendar invitations and RSVP confirmations
- Emails sent by the user themselves
- Threads where the user has already replied (the most recent message in the thread is from the user)
- Purely informational messages with no question, request, or action needed

**Include** (draft a reply):
- Direct emails from a person that contain a question, request, or require acknowledgement
- When in doubt, include the email -- it is better to draft an unnecessary reply (the user can delete it) than to miss one that needs a response

For each skipped email, record the subject, sender, and reason for skipping.

If no emails need a reply after triage, present the triage summary and stop.

### Step 3: Draft replies in the user's voice
**Skill**: `email-voice-draft`
**Input**: Each email from `actionable_emails` (one at a time), plus any user-provided `reply_guidance`
**Output** → `draft_replies`

For each email in `actionable_emails`, read and follow the instructions in `~/.agents/skills/email-voice-draft/SKILL.md`.

Pass the email data as the email thread input:
- `from`: the sender
- `subject`: the subject line
- `body`: the most recent message body
- `thread_history`: prior messages in the thread (from `thread_messages`)
- `thread_id`: the Gmail thread ID
- `message_id`: the Gmail message ID (for reply threading)

If the user provided `reply_guidance`, pass it through.

The email-voice-draft skill will load the voice profile and business context (already in context from the preamble), search Notion for relevant knowledge, and compose the reply.

Collect the `draft_reply` output from each invocation. If drafting fails for one email, record the error and continue with the remaining emails.

### Step 4: Save drafts to Gmail
**Skill**: `gmail-draft`
**Input**: Each `draft_reply` from step 3 (one at a time)
**Output** → `draft_confirmations`

For each `draft_reply`, read and follow the instructions in `~/.agents/skills/gmail-draft/SKILL.md`.

Pass the following fields:
- `to`: recipient address
- `subject`: reply subject line
- `body`: the draft reply text
- `thread_id`: Gmail thread ID (if present, so the draft is threaded correctly)
- `in_reply_to`: the message ID for reply headers (if present)

Collect the confirmation (draft_id, summary) for each. If saving fails for one draft, record the error and continue with the remaining drafts.

## Output

Present a summary to the user:

**Drafts created**: list each draft with the recipient, subject, and any Notion pages that informed the reply.

**Skipped**: list each skipped email with the sender, subject, and reason.

**Errors** (if any): list any emails where drafting or saving failed, with the error detail.

Remind the user that all drafts are in their Gmail drafts folder for review. Nothing has been sent.
