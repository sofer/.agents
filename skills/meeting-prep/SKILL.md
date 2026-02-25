---
name: "meeting-prep"
description: "Check calendar, research attendees, and produce a briefing document for each upcoming meeting"
type: composite
depends_on:
  - calendar-fetch
  - contact-research
  - notion-query
  - meeting-context
---

# Meeting prep

## Purpose

Prepare briefing documents for upcoming meetings so the user walks in prepared. For each meeting on the calendar, the twin researches attendees, retrieves related business documentation, and produces a briefing containing attendee profiles, meeting purpose, a suggested agenda, and questions to ask.

## Config loading

Before starting the steps below:
1. Read `~/.agents/config/voice-profile.yaml` for voice and tone rules
2. Read all `.yaml` files from `~/.agents/config/business-context/` for domain knowledge (company info, offerings, contacts, terminology)
3. If any required config is missing, stop and report the expected path

## Steps

### Step 1: Fetch upcoming calendar events
**Skill**: `calendar-fetch`
**Input**: Time range from the user's request, or defaults (now to 24 hours from now)
**Output** → `calendar_events`

Read and follow the instructions in `~/.agents/skills/calendar-fetch/SKILL.md`.
Pass through any time range the user specified. The result is a list of upcoming calendar events, each with title, time, attendees, description, and metadata.

If no events are found, stop and report: "No upcoming meetings found in the requested time range. No briefings to prepare."

If calendar-fetch fails (e.g. Google Calendar MCP server unavailable), stop and report the error. Calendar data is required to proceed.

### Step 2: Research attendees
**Skill**: `contact-research`
**Input**: Attendee names and email addresses from `calendar_events`
**Output** → `attendee_profiles`

For each meeting in `calendar_events`, identify the external attendees (exclude the user's own email address). For each attendee (up to 5 per meeting):

1. Check whether a profile for this person (by email) already exists in context from a previous meeting's research. If so, reuse it rather than researching again.
2. If no existing profile is found, read and follow the instructions in `~/.agents/skills/contact-research/SKILL.md`, providing the attendee's name and email as input.

Collect all attendee profiles. Each profile is labelled with the attendee's email and associated with the meeting(s) they attend.

If a meeting has no external attendees, skip this step for that meeting and note that no attendee research was needed.

If contact-research fails for a specific attendee, note the failure and continue with the remaining attendees. Do not stop the entire process.

### Step 3: Retrieve related business context
**Skill**: `notion-query`
**Input**: Search queries derived from the meeting title and description in `calendar_events`
**Output** → `business_context`

For each meeting in `calendar_events`:

1. Derive a search query from the meeting title (remove generic words like "meeting", "call", "sync", "catch-up") and any substantive terms from the description.
2. Read and follow the instructions in `~/.agents/skills/notion-query/SKILL.md`, using the derived search query.
3. If results are found, note the most relevant pages (titles, URLs, and key content) for use in the next step.

If notion-query fails (e.g. Notion MCP server unavailable), note the limitation and continue to the next step. Notion context is valuable but not required.

### Step 4: Produce meeting context
**Skill**: `meeting-context`
**Input**: Each event from `calendar_events`, enriched with `attendee_profiles` and `business_context`
**Output** → `meeting_briefings`

For each meeting in `calendar_events`:

1. Ensure the event data, any attendee profiles for this meeting (from step 2), and any Notion results for this meeting (from step 3) are all available in context.
2. Read and follow the instructions in `~/.agents/skills/meeting-context/SKILL.md`, providing the calendar event as input.
3. The skill produces: meeting purpose, key topics, suggested agenda, questions to ask, prior context, and attendee notes.

If meeting-context fails for a specific meeting (e.g. the event has no title), report the error for that meeting and continue with the remaining meetings.

## Output

Present a briefing document for each upcoming meeting. Use the following format for each briefing:

```
---

# Meeting briefing: [title]

**When**: [start_time] to [end_time] ([duration] minutes)
**Location**: [location or meeting link, or "Not specified"]
**Attendees**: [comma-separated list of attendee names]

## Attendee profiles

[For each researched attendee, include their profile summary from contact-research.
Format each as:]

### [Name] ([email])
[Narrative summary from contact-research, including role, company, prior interactions]

[If no attendees or no external attendees, state: "No external attendees for this meeting."]

## Meeting purpose

[Purpose statement from meeting-context]

## Key topics

[Numbered list of topics from meeting-context, each with a brief explanation]

## Suggested agenda

[Agenda table from meeting-context with items, durations, and notes]

## Questions to ask

[Bulleted list of questions from meeting-context]

## Prior context

[Notion references and recent email threads from meeting-context, if available.
Omit this section if no prior context was found.]

## Data sources

[Note which sources were available and used, e.g.:
"Context drawn from: Google Calendar, contact research (Gmail, Notion, web), Notion query, meeting context analysis. Gmail was unavailable for attendee research."]

---
```

If multiple meetings were found, present each briefing in sequence, ordered by meeting start time. Separate each briefing with a horizontal rule (`---`).

After all briefings, provide a brief summary: "Prepared [N] briefing(s) for meetings between [start] and [end]."
