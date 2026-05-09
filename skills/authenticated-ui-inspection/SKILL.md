---
name: authenticated-ui-inspection
description: Use when inspecting, testing, or reproducing behaviour in a non-public web app that requires a recognised login session, cookie, token, or browser-authenticated user.
---

# Authenticated UI inspection

## Purpose

Inspect a web application as an authenticated user without exposing secrets. Establish or verify session access, open target URLs, capture visible evidence, and report what was actually observed.

## Safety rules

- Do not ask the user to paste cookies, tokens, passwords, or magic links into chat.
- Prefer a browser session the user authenticates manually.
- If a local cookie or credential file is needed, ask before reading it and do not print secret values.
- Do not mutate production data unless the user explicitly asks for that action.
- Do not send emails, submit forms with external effects, charge money, deploy, or post comments without confirmation.
- Distinguish observed UI facts from inferences based on code or data.

## Workflow

1. Identify the target URL, required user role, and whether read-only inspection is enough.
2. Open the URL in the in-app browser when available. For local targets, use the browser-use plugin.
3. If unauthenticated, ask the user to complete login in the browser session or provide an approved local authentication method.
4. Verify authentication with a low-risk page or user endpoint, for example dashboard, account, or "who am I".
5. Navigate to each target page and record:
   - URL
   - user role if visible or known
   - visible labels, counts, copy, and error states
   - actions taken
   - screenshots when useful
6. For reproduction steps, keep the path short and reset state only through existing UI controls unless the user approves data changes.

## Evidence standard

Use these labels in findings:

- **Observed in UI**: directly seen in the authenticated browser.
- **Inferred from code**: based on app/source inspection only.
- **Inferred from data**: based on database/API data only.
- **Not verified**: plausible but not checked in UI.

## Local auth material

When a project defines a local env var or cookie convention, read only the minimum needed values, do not print them, and construct the browser or request session from those values. Keep app-specific cookie names and URLs in project or domain-specific skills, not in this generic skill.
