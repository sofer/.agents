---
name: "contact-research"
description: "Research a person given their name and email, returning a brief profile with role, company, LinkedIn summary, and previous interactions"
type: atomic
input: "Person's name (string, required) and email address (string, required)"
output: "Contact profile: role, company, LinkedIn summary, email interaction history, Notion mentions, and a narrative summary"
---

# Contact research

## Purpose

Research a person given their name and email address, producing a brief profile that includes their role, company, public professional presence, and any previous interactions found in Gmail or Notion. This skill supports the meeting prep twin by ensuring the user knows who they are meeting.

## Instructions

### 1. Validate input

Confirm that both a **name** and an **email** are provided. If either is missing, stop and report: "Contact research requires both a name and an email address. Missing: {field}."

Extract the email domain (the part after `@`). If the domain is not a common personal email provider (gmail.com, googlemail.com, outlook.com, hotmail.com, yahoo.com, icloud.com, me.com, protonmail.com, proton.me), treat it as a potential company domain.

### 2. Check known contacts

Read `~/.agents/config/business-context/contacts.yaml` if it exists. Search for an entry matching the person's name or email address. If found, note any known details (role, company, relationship notes) for inclusion in the profile.

If the file does not exist, skip this step silently.

### 3. Search Gmail for previous interactions

Check which Gmail tools are available:

1. **Gmail MCP server** (preferred): look for available MCP tools related to Gmail or Google. If found, use them to search for messages.
2. **Gmail API via environment variable** (fallback): check for a `GMAIL_ACCESS_TOKEN` environment variable.
3. **Neither available**: skip this step and note that email history was not available.

If Gmail is available, search for email threads with this person:

- Search query: `from:{email} OR to:{email}`
- Limit to the 10 most recent results
- For each result, note the **subject**, **date**, and a brief **snippet** of the content

This provides the user with a sense of their prior relationship and recent topics of conversation.

### 4. Search Notion for mentions

Check whether the Notion MCP tools are available:

- Required tool: `mcp__claude_ai_Notion__notion-search`

If unavailable, skip this step and note that Notion was not available.

If available, search for the person's name:

1. Call `mcp__claude_ai_Notion__notion-search` with `query` set to the person's full name
2. For each result, note the **page title**, **URL**, and **content snippet**
3. If the person's name is common and returns many irrelevant results, try a more specific search combining the name with the email domain (e.g. "Alice Smith acme-corp")

This reveals whether the person has been mentioned in meeting notes, project pages, or other business documentation.

### 5. Search the web for public profile information

Check whether the WebSearch tool is available. If unavailable, skip this step and note that web search was not available.

If available, perform the following searches:

1. **LinkedIn search**: search for `{name} {company_domain} LinkedIn` (using the email domain if it appears to be a company domain, otherwise just the name)
2. **General professional search**: if the LinkedIn search is insufficient, search for `{name} {company_domain}` to find company pages, bios, or press mentions

From the results, extract:
- **Role/title**: the person's current job title
- **Company**: the person's current employer or organisation
- **LinkedIn summary**: a brief summary of their professional background (2-3 sentences)
- **Other relevant context**: any notable public information (e.g. published articles, speaking engagements, open-source work)

Do not fabricate information. If a detail cannot be confirmed from the search results, omit it.

### 6. Synthesise the profile

Combine all findings into a structured contact profile:

```yaml
name: "{person's full name}"
email: "{person's email}"
role: "{job title, if found}"
company: "{company or organisation, if found}"
linkedin_summary: "{brief professional summary, if found}"
email_interactions:
  - subject: "{email subject}"
    date: "{date}"
    snippet: "{brief excerpt}"
notion_mentions:
  - title: "{page title}"
    url: "{page URL}"
    snippet: "{content excerpt}"
summary: "{3-5 sentence narrative profile}"
```

Write the **summary** as a brief narrative (3-5 sentences) that answers:
- Who is this person? (role, company)
- What is their professional background? (LinkedIn or web findings)
- What is the user's existing relationship with them? (email history, Notion mentions)
- What should the user know before meeting them?

If a section has no data (e.g. no email interactions were found), omit that section from the output rather than including an empty list.

## Error handling

- **Missing name or email**: stop and report which required field is missing.
- **Gmail unavailable**: skip the Gmail search. Note in the output: "Email interaction history not available (Gmail not configured)."
- **Gmail authentication failure**: skip the Gmail search. Note: "Email interaction history not available (Gmail authentication failed)."
- **Notion MCP server unavailable**: skip the Notion search. Note in the output: "Notion mentions not available (Notion MCP server not configured)."
- **WebSearch tool unavailable**: skip the web search. Note in the output: "Public profile information not available (web search not configured)."
- **All sources unavailable**: return a minimal profile containing only the provided name, email, and the email domain as a potential company signal. The summary should state that no research sources were available and list which integrations need to be configured.
- **No results from any source**: return a profile with the provided name and email. The summary should state that no prior interactions or public profile information was found for this person.

## Output format

The skill produces a contact profile. When used as a step in a composite skill, the output is labelled (e.g. `contact_profile`) and available to subsequent steps via the agent's context.

```yaml
name: "Alice Smith"
email: "alice@acme-corp.com"
role: "VP of Engineering"
company: "Acme Corp"
linkedin_summary: "Engineering leader with 15 years of experience in distributed systems. Previously led platform teams at BigTech and MidSize. Based in London."
email_interactions:
  - subject: "Re: Partnership discussion"
    date: "2026-02-20"
    snippet: "Thanks for the proposal. Let me review with my team..."
  - subject: "Introduction from Bob"
    date: "2026-01-15"
    snippet: "Hi, Bob suggested we connect regarding..."
notion_mentions:
  - title: "Acme Corp partnership notes"
    url: "https://notion.so/workspace/Acme-Corp-abc123"
    snippet: "Met Alice at the conference. She's interested in..."
summary: "Alice Smith is VP of Engineering at Acme Corp, with 15 years of experience in distributed systems. You have exchanged emails about a partnership proposal, most recently on 20 February 2026. She was introduced by Bob in January and is mentioned in your Acme Corp partnership notes in Notion. She appears to be the key technical decision-maker for their side of the partnership."
```
