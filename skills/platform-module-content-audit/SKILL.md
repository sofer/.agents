---
name: platform-module-content-audit
description: Use when auditing a FAC platform Learn module, workshop module, lesson content, exercise content, module progress, or learning module report.
---

# Platform module content audit

## Purpose

Produce a repeatable content audit report for a Learn module by ID. Combine module data, static checks, relevant UI code, and optional authenticated UI evidence. Separate module-specific content fixes from platform guardrails.

## Workflow

1. Confirm scope: module ID, audience role (`WORKSHOP`, learner, admin), whether fixes are requested, and whether authenticated UI evidence is required.
2. Read `references/fac-cra-learn.md` for FAC Learn schema and UI-code pointers.
3. Use `postgres-query` for read-only data extraction and connection handling.
4. Export module JSON with `scripts/export-module-content.sql`.
5. Run `scripts/analyse-module-content.mjs` on the JSON to get structural checks.
6. Inspect relevant app code for UI behaviour before writing reproduction steps.
7. If authenticated browser access is needed, use `authenticated-ui-inspection`.
8. Write a markdown report under `docs/investigations/` unless the user requests another location.

## Extraction

After `postgres-query` has established the read-only connection method, run the SQL through `psql`, substituting the module ID:

```bash
psql "$CONNECTION_URI" --no-psqlrc -v ON_ERROR_STOP=1 -v module_id=228 \
  -t -A -f ~/.agents/skills/platform-module-content-audit/scripts/export-module-content.sql \
  -o /tmp/module_228_content.json
```

`CONNECTION_URI` means the safe connection URI chosen by `postgres-query`. Do not print connection strings or credentials. Do not query learner personal data unless it is required for the stated audit. Keep production connection setup in `postgres-query`, not in this skill.

## Static checks

Run:

```bash
node ~/.agents/skills/platform-module-content-audit/scripts/analyse-module-content.mjs /tmp/module_228_content.json
```

Treat these as starter findings, not final truth. Verify likely learner impact against UI code and, where possible, the authenticated site.

Core checks:

- active exercises under deleted or hidden lessons
- learner-visible exercise count versus module-level active exercise count
- duplicate lesson or exercise order positions
- duplicate prompts or titles
- empty lesson summaries or missing type-specific exercise fields such as `explanation_text`, `question_text`, answers, choices, code tests, or SQL database URLs
- truncated titles
- generic titles such as `Section`
- internal wording such as `file 03`, `TODO`, `FIXME`
- KSB count and metadata anomalies

## UI investigation

Read the app code enough to know where the issue appears. Use `references/fac-cra-learn.md` for FAC Learn code pointers.

Report UI reproduction steps as fast user actions, not SQL. If UI access has not been live-verified, state that clearly.

## Report format

Use this structure:

```markdown
# Module <id> content audit

## Scope and method
## Summary
## Issue 1: <user-impact title>
Severity: Important

### Problem
### Quick UI reproduction
### Evidence
### Fix
```

Use detailed copy excerpts only where the problem is hard to understand without seeing the content, such as swapped summaries or ambiguous wording.

## Fix guidance

Classify fixes:

- **Immediate content fix**: data/content changes for the target module.
- **Platform guardrail**: code or validation that prevents recurrence.
- **Verification gap**: what remains unverified because of auth, data, or environment constraints.

Never apply production writes, send emails, post comments, or mutate learner data without explicit confirmation.
