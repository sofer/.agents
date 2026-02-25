---
name: "calendar-fetch"
description: "Fetch upcoming calendar events from Google Calendar"
type: atomic
input: "Optional time range (start, end), optional calendar ID, optional max results"
output: "List of calendar events with title, time, attendees, description, and metadata"
---

# Calendar fetch

## Purpose

Fetch upcoming calendar events from Google Calendar so that downstream skills (such as meeting prep) know what meetings are coming. This is a read-only, data-retrieval skill.

## Instructions

### 1. Resolve parameters

Determine the fetch parameters from the invoking request. Apply these defaults for any parameter not specified:

- **time_range_start**: current date and time (now)
- **time_range_end**: 24 hours from now
- **calendar_id**: `primary`
- **max_results**: `20`

If the caller provides a time range, validate that the end is after the start. If invalid, stop and report the error.

### 2. Discover Google Calendar tools

Check for available Google Calendar MCP tools. Look for tools with names containing `google` and `calendar` (e.g. `google_calendar_list_events`, `list_events`, or similar).

If no Google Calendar MCP tools are available, stop and report:

> Google Calendar integration is not available. Ensure the Google Calendar MCP server is configured in your agent settings.

### 3. Fetch events

Call the Google Calendar MCP tool to list events with these parameters:

- **calendarId**: the resolved calendar ID
- **timeMin**: the resolved start time in ISO 8601 format
- **timeMax**: the resolved end time in ISO 8601 format
- **maxResults**: the resolved maximum number of events
- **singleEvents**: `true` (expand recurring events into individual instances)
- **orderBy**: `startTime`

Adapt the parameter names to match the MCP tool's expected interface. The MCP tool may use camelCase, snake_case, or other naming; map accordingly.

### 4. Process results

From the raw API response, extract and structure each event. Exclude any event with a status of `cancelled`.

For each remaining event, extract:

- **title**: the event summary/title
- **start_time**: when the event starts (ISO 8601)
- **end_time**: when the event ends (ISO 8601)
- **attendees**: list of attendees, each with email, display name (if available), and response status (accepted, declined, tentative, needsAction)
- **description**: the event description (may be empty)
- **location**: the event location (may be empty)
- **meeting_link**: video conferencing link from conferenceData or the location field if it contains a URL (may be empty)
- **organiser**: the organiser's email address
- **event_id**: the unique event identifier
- **calendar_id**: which calendar this event belongs to
- **status**: confirmed or tentative
- **is_recurring**: whether this is part of a recurring series (true if recurringEventId is present)

### 5. Return structured output

Present the events in the following format, one block per event, ordered by start time:

```
## Upcoming events

### [title]
- **When**: [start_time] to [end_time]
- **Attendees**: [name <email> (status)], [name <email> (status)], ...
- **Description**: [description or "None"]
- **Location**: [location or "None"]
- **Meeting link**: [meeting_link or "None"]
- **Organiser**: [organiser]
- **Status**: [status]
- **Recurring**: [yes/no]
- **Event ID**: [event_id]
```

If no events are found in the specified range, return:

```
## Upcoming events

No events found between [time_range_start] and [time_range_end].
```

## Error handling

- If the Google Calendar MCP server is not available, stop and report: "Google Calendar integration is not available. Ensure the Google Calendar MCP server is configured in your agent settings."
- If authentication fails (expired token, missing credentials), stop and report: "Google Calendar authentication failed. Check that your credentials are valid and the MCP server has the required permissions (calendar.readonly or calendar.events.readonly scope)."
- If the specified calendar is not found, stop and report: "Calendar '[calendar_id]' not found. Check the calendar ID and ensure you have access to it."
- If a network or rate-limit error occurs, report the error and suggest retrying. Do not retry automatically.

## Output format

A structured list of calendar events as described in step 5, suitable for consumption by composite skills via the context window. Each event includes title, time, attendees, description, location, meeting link, organiser, status, recurrence flag, and event ID.

When used within a composite skill, this output is labelled as specified by the composite step (e.g. `calendar_events`) and is available to all subsequent steps.
