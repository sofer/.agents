---
name: code-review
description: Review code changes for bugs, security issues, regressions, test gaps, and fit with the stated goal. Use for PRs, branches, commit ranges, staged changes, or files, especially before committing or shipping platform work.
---

# Code review

## Purpose

Provide a fresh, critical review of code changes. Prioritise correctness, security, behavioural regressions, ownership boundaries, and missing tests.

## Inputs

Accept any of:
- PR URL or number.
- Branch name.
- Commit range.
- Staged or unstaged local diff.
- File list.
- Spec, plan, or acceptance criteria.

If the goal of the change is unclear, infer from PR text, commit messages, docs, tests, or surrounding code. Ask only if ambiguity affects the review.

## Safety

- Reading PRs, diffs, files, and local test results is allowed.
- Do not post GitHub comments, approve, request changes, push, merge, or create PRs without explicit confirmation.
- Do not modify code during a review unless the user explicitly asks for fixes.
- Preserve user work. Do not revert or overwrite unrelated changes.

## Review process

1. Identify the scope:
   - files changed
   - intended behaviour
   - tests changed or missing
   - shared files or boundaries touched
2. Inspect repo instructions, especially `AGENTS.md`, when reviewing non-trivial work.
3. Review the diff and relevant surrounding code.
4. Check the change against:
   - stated goal or acceptance criteria
   - existing patterns and interfaces
   - security and privacy
   - error handling
   - data and migration safety
   - auth, email, payments, permissions, or production-impacting behaviour
   - test coverage and verification quality
5. Run or inspect relevant checks when feasible. If checks are not run, state the gap.
6. Produce findings ordered by severity.

## Platform mode

For `~/code/fac-cra/`, always check:
- whether the change stayed inside Distribution or Partners boundaries
- whether shared files were touched and why
- whether the change could disrupt the CTO's fast-moving work
- whether the test harness gives real confidence
- whether end-to-end verification is required for email, auth links, registration, or multi-step flows

Treat unexplained shared-boundary changes as at least important.

## Severity

- `Blocking`: must fix before merge, release, or commit. Examples: data loss, security flaw, broken core behaviour, unsafe migration, auth bypass.
- `Important`: should fix before shipping unless there is a deliberate tradeoff. Examples: likely bug, weak test harness, brittle integration, unclear shared-boundary impact.
- `Minor`: worth considering, but does not block. Examples: small maintainability issue, local naming inconsistency.

Avoid style-only comments unless they create real maintainability or correctness risk.

## Output

Lead with findings. If there are no findings, say so clearly.

```markdown
## Findings

1. [Severity] [Title] - [file:line]
   [Why this matters.]
   Suggested fix: [Concrete action.]

## Open questions
- [Question that affects correctness, scope, or risk.]

## Verification
- [Checks run or reviewed.]
- [Checks not run and why.]

## Boundary notes
- [For platform work: Distribution/Partners status and shared files touched.]

## Summary
[One or two sentences only.]
```

## GitHub review posting

If the user asks to post review comments:
1. Show the exact review body and inline comments first.
2. Ask for confirmation.
3. Post only after confirmation.
4. Keep comments concise and actionable.
5. Never include AI-tool attribution.

