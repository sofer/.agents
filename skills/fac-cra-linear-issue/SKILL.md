---
name: fac-cra-linear-issue
description: Use when managing Linear issues for agreed work in /Users/dsofer/code/fac-cra, especially creating an issue before implementation or closing it after the final commit.
---

# FAC CRA Linear Issue

## Purpose

Use Linear as lightweight issue tracking for personal work in `fac-cra` without making issue admin noisier than the implementation.

This skill is repo-specific. Use it only when the current repo is `/Users/dsofer/code/fac-cra`, or when the user explicitly asks to manage a Linear issue for `fac-cra`.

## Before using

- Prefer the Linear MCP server. If no Linear tools are available, tell the user to connect it with `codex mcp add linear --url https://mcp.linear.app/mcp` and `codex mcp login linear`.
- Read `references/linear-fields.md` for the configured Linear team, workflow states, labels, and templates. If values are unknown, discover them with Linear MCP instead of guessing.
- Do not use API keys or secrets from the repo. If direct API fallback is needed, ask before using any token or environment variable.
- Do not create a Linear issue until the user has decided what they want to build and the problem statement is stable enough to avoid churn.

## Create an issue

1. Confirm the shared understanding in chat:
   - problem statement
   - scope
   - non-goals
   - ownership boundary, especially Distribution, Partners, or shared-boundary work
   - verification plan
   - external side-effect limits
2. Create the Linear issue in the configured team.
3. Assign it to the current user.
4. Set the configured status, labels, project, or cycle only when known.
5. Use this issue body shape:

```markdown
## Problem
[What is wrong, missing, or valuable.]

## Scope
- [What this task includes.]

## Non-goals
- [What this task will not change.]

## Ownership and risk
- [Owned area or shared-boundary files likely to be touched.]
- [Auth, email, data, deployment, or external side-effect risks.]

## Verification
- [Focused tests, typecheck/lint, build, browser checks, or end-to-end checks.]
```

6. Return the issue identifier, URL, and a suggested branch name such as `linear/<identifier-lowercase>-short-slug`.

## Close an issue

1. Inspect the current branch and recent commits. Do not assume the final commit if the history is ambiguous.
2. If the work will be squash-merged later and there is no final commit yet, add a comment with the branch or PR URL instead of claiming a final commit.
3. If there is a final commit, add a Linear comment:

```markdown
Completed in [commit-sha-or-link].

Verification:
- [Commands or checks run.]

Notes:
- [Any residual deploy risk or follow-up.]
```

4. Move the issue to the configured done state.
5. Report the Linear issue URL and the commit link/comment that was added.

## Guardrails

- Ask before posting comments that mention people, customers, production incidents, or sensitive details.
- Ask before creating, closing, or materially editing a Linear issue if the target issue is unclear.
- Keep the issue description concise and implementation-neutral. Linear should track the problem and completion evidence, not duplicate every design note.
- For platform work, keep the final response aligned with repo instructions: boundaries touched, shared files and why, verification, and remaining deploy risk.
