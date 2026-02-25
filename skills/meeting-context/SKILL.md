---
name: "meeting-context"
description: "Determine why a meeting is happening and what should be discussed"
type: atomic
input: "A calendar event object with title, time, attendees, description, organiser, and location"
output: "Meeting purpose, key topics, suggested agenda, and questions to ask"
---

# Meeting context

## Purpose

Analyse a calendar event to determine why the meeting is happening and what should be discussed. Produces a structured meeting briefing with purpose, key topics, a suggested agenda, and questions to ask. Enriches the briefing with context from Notion and Gmail when available.

## Config loading

Before executing, read the available business context:

1. Read all `.yaml` files from `~/.agents/config/business-context/` for domain knowledge (company info, offerings, contacts, terminology)
2. If the directory does not exist or is empty, proceed without business context and note this in the output

## Instructions

### 1. Parse the event data

Identify the calendar event data in context. The event should contain:

- **title** (required): the event summary
- **start_time** (required): when the meeting starts
- **end_time** (required): when the meeting ends
- **attendees** (optional): list of people with email, display name, and response status
- **description** (optional): event description or notes
- **organiser** (optional): the organiser's email address
- **location** (optional): meeting location or video link
- **meeting_link** (optional): video conferencing link
- **is_recurring** (optional): whether the meeting recurs

If no event data is found in context, stop and report: "No calendar event data found. This skill requires a calendar event as input (typically provided by the calendar-fetch skill in a composite workflow)."

If the event has no title, stop and report: "The calendar event has no title. A title is required to determine meeting context."

Calculate the meeting duration from start_time and end_time.

### 2. Derive search queries

From the event data, derive search queries to find related context:

- **Topic queries**: extract key terms from the meeting title and description. Remove generic words (e.g. "meeting", "call", "sync", "catch-up") to focus on substantive terms.
- **Attendee queries**: for each attendee (up to 5, excluding the user's own email address), note their name and email for searching prior interactions.
- **Combined queries**: if the title references a specific project, product, or person, create queries that combine these with business context terms.

### 3. Search Notion for related context

If the Notion MCP server is available (tools `mcp__claude_ai_Notion__notion-search` and `mcp__claude_ai_Notion__notion-fetch` exist):

1. Search Notion using the topic queries derived in step 2. Call `mcp__claude_ai_Notion__notion-search` with each query, using `query_type: "internal"`.
2. If attendees are present, also search for each attendee's name.
3. From the combined search results, identify the top 3 most relevant pages (by title and snippet relevance to the meeting).
4. Fetch the full content of those top 3 pages using `mcp__claude_ai_Notion__notion-fetch`.
5. Note the titles and URLs of up to 5 relevant pages for the output's prior context section.

If the Notion MCP server is not available, skip this step. Note in the output: "Notion was unavailable; business documentation context could not be retrieved."

If Notion searches return no results, proceed without Notion context.

### 4. Search Gmail for prior email threads

If Gmail MCP tools are available (look for tools with names containing `gmail` or `google_mail`):

1. For each attendee (up to 5), search for recent email threads using a query like `from:{email} OR to:{email}`, limited to the most recent 5 threads.
2. For each thread found, note the subject, date, and a brief summary of the conversation.

If no Gmail MCP tools are available, check for a `GMAIL_ACCESS_TOKEN` environment variable and use the Gmail API:

1. Search: `GET https://gmail.googleapis.com/gmail/v1/users/me/messages?q=from:{email} OR to:{email}&maxResults=5` with `Authorization: Bearer {GMAIL_ACCESS_TOKEN}`
2. Fetch message details for each result.

If neither Gmail MCP nor API is available, skip this step. Note in the output: "Gmail was unavailable; prior email context could not be retrieved."

If no email threads are found for an attendee, note that no prior email interactions were found for them.

### 5. Synthesise the meeting context

Using all gathered information (event data, business context, Notion content, email history), produce the following:

#### Purpose

Write a concise statement (1-2 sentences) explaining why this meeting is happening. Base this on:
- The event title and description (primary signals)
- Related Notion content (what project or topic is this connected to?)
- Recent email threads (what has been discussed recently?)
- Whether the meeting is recurring (regular check-ins have a different flavour than one-off meetings)

If the event data is sparse, state the purpose with lower confidence and note what information was missing.

#### Key topics

List 3-7 topics likely to be discussed, ordered by relevance. For each topic, include a brief explanation of why it is relevant. Draw from:
- Explicit mentions in the event description
- Active projects or open items found in Notion
- Unresolved threads or recent topics from email
- Business context (e.g. if the meeting relates to a known offering or project)

For recurring meetings, prioritise recent updates, blockers, and next steps over background context.

#### Suggested agenda

Create a proposed agenda that fits within the meeting duration. Each item should have:
- A short description
- An allocated duration in minutes
- Brief notes on what to cover

Rules for agenda construction:
- Total time must not exceed the meeting duration
- For meetings of 15 minutes or less: 2-3 items maximum
- For meetings of 30 minutes: 3-5 items
- For meetings over 60 minutes: consider suggesting a 5-minute break
- If the event description already contains an agenda, use it as the starting point and enrich rather than replace
- Include a brief opening (1-2 minutes) and wrap-up with next steps (2-3 minutes)

#### Questions to ask

List 3-7 specific, actionable questions the user should consider asking during the meeting. These should:
- Address open items or unknowns identified in the gathered context
- Seek clarity on decisions, timelines, or commitments
- Be tailored to the meeting's purpose and attendees
- For new contacts (no prior interactions found), include introductory or rapport-building questions
- For recurring meetings, focus on progress, blockers, and forward-looking questions

#### Prior context (if available)

If Notion references or email threads were found, include them:
- **Notion references**: list relevant pages with title, URL, and a note on why they are relevant
- **Email threads**: list recent threads with subject, date, and a one-sentence summary

#### Attendee notes (if attendees are present)

For each researched attendee, include:
- Their name and email
- A brief note on relevant prior interactions (from Notion or email)
- If no prior interactions were found, note this and suggest introductory topics

### 6. Return the output

Present the meeting context in the following format:

```
## Meeting context: [title]

**When**: [start_time] to [end_time] ([duration] minutes)
**Attendees**: [list of names]

### Purpose
[1-2 sentence statement]

### Key topics
1. **[Topic]**: [brief explanation]
2. **[Topic]**: [brief explanation]
...

### Suggested agenda
| # | Item | Duration | Notes |
|---|------|----------|-------|
| 1 | [item] | [X] min | [context] |
| 2 | [item] | [X] min | [context] |
...
| | **Total** | **[Y] min** | |

### Questions to ask
- [Question]
- [Question]
...

### Prior context
**Notion references:**
- [Page title](url) -- [relevance note]
...

**Recent email threads:**
- [Subject] ([date]) -- [summary]
...

### Attendee notes
- **[Name]** ([email]): [context from prior interactions]
...

### Data sources
[Note which sources were available and which were not, e.g. "Context drawn from: event data, Notion (3 pages), Gmail (2 threads). Gmail was unavailable for attendee research."]
```

If prior context or attendee notes sections would be empty, omit them from the output.

## Error handling

- **No event data in context**: stop and report "No calendar event data found. This skill requires a calendar event as input (typically provided by the calendar-fetch skill in a composite workflow)."
- **Event has no title**: stop and report "The calendar event has no title. A title is required to determine meeting context."
- **Notion MCP unavailable**: do not stop. Skip Notion search, note the limitation in the output, and proceed.
- **Gmail unavailable**: do not stop. Skip email search, note the limitation in the output, and proceed.
- **Business context config missing**: do not stop. Proceed without business context and note the limitation.
- **No search results from Notion or Gmail**: not an error. Proceed with available data.

## Output format

A structured meeting briefing as described in step 6, suitable for consumption by composite skills via the context window. The output includes: meeting purpose, key topics, suggested agenda, questions to ask, prior context (when available), attendee notes (when available), and a data sources note.

When used within a composite skill, this output is labelled as specified by the composite step (e.g. `meeting_context`) and is available to all subsequent steps.
