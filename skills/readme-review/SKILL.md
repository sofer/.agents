---
name: readme-review
description: Review the project README to understand what it does and suggest a recommended next step. Use when starting work on an unfamiliar project.
---

# README review

Quickly orient yourself in a new project by reviewing the README and suggesting what to do next.

## Process

### Step 1: Find and read the README

1. Look for README files in the project root (README.md, README, README.txt, readme.md)
2. Read the README content thoroughly
3. If no README exists, note this and scan the project structure instead

### Step 2: Provide a summary

Write a concise summary covering:

- **Purpose**: What does this project do? (1-2 sentences)
- **Tech stack**: Key languages, frameworks, and tools
- **Status**: Active development, maintenance mode, or unclear
- **Setup**: How to get started (if documented)

Keep the summary brief and focused on essentials.

### Step 3: Recommend a next step

Based on the project context and README content, suggest ONE recommended next action. Consider:

**For new/unfamiliar projects:**
- If requirements are unclear: suggest `/intent` to clarify goals
- If there's a backlog or issues list: suggest reviewing it
- If setup instructions exist: suggest running the project locally

**For projects with clear direction:**
- If there's a documented contribution guide: point to it
- If tests exist: suggest running them to verify the setup
- If there's a clear next feature or bug: suggest starting there

**For projects lacking documentation:**
- Suggest creating or improving the README
- Suggest using `/requirements` to document what exists

## Output format

```
## Project summary

[Brief summary of what the project does]

**Tech stack:** [languages, frameworks, tools]
**Status:** [development stage or activity level]

## Recommended next step

[One clear recommendation with rationale]

To proceed: [specific command or skill to invoke, if applicable]
```

## Tips

- Keep it short; this is orientation, not deep analysis
- Be honest if the README is sparse or unclear
- Tailor recommendations to what the user might actually want to do
- Reference specific skills (e.g., `/intent`, `/requirements`, `/orchestrate`) when they fit
