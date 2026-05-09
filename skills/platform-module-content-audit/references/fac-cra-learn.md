# fac-cra Learn audit reference

Use this reference only when auditing `~/code/fac-cra/` Learn modules.

## Data extraction

Use `postgres-query` for production connection setup, credential handling, read-only guardrails, and tunnel details. This reference only records FAC Learn schema and code pointers.

## Main tables

- `cortex.modules`: module metadata and summary text
- `cortex.lessons`: lesson cards, lesson summaries, lesson status and order
- `cortex.exercises`: exercise content, status, type, answer snippets
- `cortex.module_to_ksb` and `oracle.ksb`: KSB mapping
- `cortex.answers`: learner submissions, query only when the audit explicitly requires learner state

## UI code to inspect

- `apps/learn/src/modules/pages/Module.js`: module page, visible exercise counts, module progress from visible lessons
- `apps/learn/src/modules/pages/Exercise.js`: exercise page, outline, progress bars
- `apps/learn/src/modules/components/Lesson.Outline.js`: lesson card, reset button, exercise list titles
- `packages/dashboard/src/dashboard/components/Dashboard.Activity.js`: dashboard module percentages
- `api/domains/learning/queries.ts`: learner module payloads
- `api/domains/reports/queries.ts`: dashboard and reporting payloads

## Authenticated UI surfaces

Use `authenticated-ui-inspection` for session handling and UI evidence. For module audits, inspect only the relevant pages, usually:

- `/m/<module_id>`
- `/m/<module_id>/l/<lesson_id>/e/<index>`
- `/dashboard`
- admin module pages only when reviewing hidden, deleted, or draft content

For local automation against FAC production, the current env convention is:

- `FAC_SESSION_COOKIE`: raw platform session cookie value
- `FAC_SESSION_COOKIE_NAME`: optional cookie name override, default `fac_session`, legacy fallback `_mlx`
- API verification endpoint: `https://api.foundersandcoders.com/g` with `query AccountsGetMe { accounts_me { role } }`

Do not print cookie values.

## Common issue classes

- Active exercises under deleted lessons. These may be hidden in Learn but counted in dashboard/reporting denominators.
- Swapped lesson summaries. Compare lesson `text` with first exercises in the lesson.
- Truncated question titles. Titles are used in breadcrumbs and outlines; full questions belong in `question_text`.
- Duplicate content after lesson split or upload.
- Internal source wording from markdown source files.
