---
name: "email-voice-draft"
description: "Draft an email reply in the user's voice using their business context and Notion knowledge"
type: atomic
input: "An email thread (from, subject, body, optional thread_history, thread_id, message_id) and optional reply_guidance"
output: "A draft reply (to, subject, body) written in the user's voice, with optional context_used listing Notion sources"
---

# Email voice draft

## Purpose

Draft a reply to an email thread that sounds like the user. The skill loads the user's voice profile and business context from configuration files, optionally enriches the reply with knowledge from Notion, and produces a draft that a downstream skill (e.g. gmail-draft) can save to Gmail. The human always reviews before sending.

## Config loading

Before drafting, read the required configuration:

1. Read `~/.agents/config/voice-profile.yaml` for voice and tone rules. Apply the `tone`, `language`, `rules`, and `avoid` fields to all written output. If this file is missing, stop and report: "Voice profile not found at ~/.agents/config/voice-profile.yaml"
2. Read all `.yaml` files in `~/.agents/config/business-context/` for domain knowledge (company identity, offerings, contacts, terminology). At minimum, `company.yaml` and `offerings.yaml` must exist. If the directory or these required files are missing, stop and report: "Business context not found at ~/.agents/config/business-context/. At minimum, company.yaml and offerings.yaml are required."
3. If optional business context files (`contacts.yaml`, `terminology.yaml`) are missing, proceed with what is available.

## Instructions

### 1. Validate the email thread

Check that the input includes an email thread with the following required fields:

- **from** -- the sender's name and/or email address
- **subject** -- the email subject line
- **body** -- the most recent message in the thread

If any of these are missing, stop and report which field(s) are absent. Do not draft a reply.

Also note any optional fields that are present:

- **thread_history** -- previous messages in the conversation
- **thread_id** -- Gmail thread ID (pass through to the output)
- **message_id** -- Message-ID of the email being replied to (pass through as `in_reply_to`)
- **reply_guidance** -- the user's instructions on what the reply should say or emphasise

### 2. Gather Notion context

Identify the key topics in the email that might have documentation in the user's Notion workspace. Consider: product or service names, processes, dates, pricing, people, or any domain-specific subject matter.

For each distinct topic worth searching:

1. Call `mcp__claude_ai_Notion__notion-search` with a concise search query derived from the topic. Set `query_type` to `"internal"`.
2. Review the results. If a result looks relevant to the email, call `mcp__claude_ai_Notion__notion-fetch` with that page's URL or ID to retrieve the full content.
3. Keep track of which Notion pages were used (title and URL) for the `context_used` output.

**Important:**
- Do not search Notion for generic topics that the business context config already covers (e.g. the company name). Notion search is for specific, detailed information.
- Limit searches to 2-3 focused queries. Do not over-search.
- If the Notion MCP tools are unavailable, proceed without Notion context. This is not a fatal error. Note that Notion context could not be retrieved.
- If searches return no relevant results, proceed without Notion context. Do not fabricate information.

### 3. Compose the reply

Draft the reply applying all of the following:

**Voice profile rules:**
- Write in the language specified (e.g. British English)
- Match the tone descriptors from the voice profile
- Follow every rule in the `rules` list
- Avoid every pattern in the `avoid` list

**Content rules:**
- Address the substance of the email. Answer questions, respond to requests, acknowledge information.
- If `reply_guidance` is provided, follow it. User guidance takes precedence over what the email asks for when they conflict.
- Incorporate relevant facts from Notion (dates, details, specifics) where they add value. Do not dump Notion content wholesale.
- Incorporate relevant knowledge from the business context config files (company positioning, offering details, terminology).
- Do not fabricate information. If the answer is not in the email, the config, or Notion, say so naturally (e.g. "I'll check and get back to you" rather than guessing).
- Do not over-elaborate. Match the length and register of the conversation. A brief email deserves a brief reply.

**Subject line:**
- If the subject already starts with "Re:", preserve it as-is.
- If the subject does not start with "Re:", prepend "Re: ".

**Recipient:**
- Set `to` to the sender of the received email (the `from` field of the input).

### 4. Return the output

Return the result in the following structure:

**draft_reply:**
- **to** -- the recipient (original sender's email address)
- **subject** -- the reply subject line
- **body** -- the draft reply text
- **thread_id** -- the Gmail thread ID, if provided in the input (pass through unchanged)
- **in_reply_to** -- the message_id from the input, if provided (pass through unchanged)

**context_used** (optional):
- A list of Notion page titles and/or URLs that informed the reply. Omit if no Notion content was used.

## Error handling

- If the voice profile is missing, stop and report: "Voice profile not found at ~/.agents/config/voice-profile.yaml"
- If the business context directory or required files are missing, stop and report: "Business context not found at ~/.agents/config/business-context/. At minimum, company.yaml and offerings.yaml are required."
- If the email thread is missing or incomplete (no from, subject, or body), stop and report which required fields are absent
- If the Notion MCP server is unavailable, proceed without Notion context (non-fatal)
- If Notion search returns no results, proceed without Notion context (non-fatal)
- If optional config files (contacts.yaml, terminology.yaml) are missing, proceed with what is available (non-fatal)

## Output format

```
draft_reply:
  to: {recipient email address}
  subject: {reply subject line}
  body: |
    {the draft reply text in the user's voice}
  thread_id: {Gmail thread ID, if provided}
  in_reply_to: {Message-ID, if provided}

context_used:
  - {Notion page title or URL}
  - {Notion page title or URL}
```

The `draft_reply` fields are structured to pass directly to the gmail-draft skill. The `context_used` list is for transparency and human review.
