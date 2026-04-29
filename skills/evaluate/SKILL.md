---
name: evaluate
description: Define evaluation criteria, tests, or quality checks for a deliverable, implementation, workflow, or recurring agent task. Use when defining done, improving a test harness, or checking whether output meets its specification.
---

# Evaluate

## Purpose

Make "done" testable before or after work is performed.

## Process

1. Identify the deliverable or behaviour being evaluated.
2. Extract claims about what must be true.
3. Convert each claim into a check:
   - automated check
   - manual check
   - human judgement rubric
4. Mark each check as:
   - `blocking`: failure means not done
   - `important`: should be fixed, but may not block
   - `nice to have`: useful but optional
5. Add edge cases most likely to reveal failure.
6. For recurring work, define a small reusable eval harness and baseline examples.

## Output

```markdown
## Evaluation checklist

### Automated checks
- [ ] [Check] (blocking|important|nice to have)
  - How to verify: [command, test, script, query, or assertion]

### Manual checks
- [ ] [Check] (blocking|important|nice to have)
  - How to verify: [steps and expected result]

### Human review criteria
- [ ] [Criterion] (blocking|important|nice to have)
  - Pass: [Observable qualities]
  - Fail: [Observable failure]

### Edge cases
- [ ] [Scenario]
  - Expected behaviour: [Expected result]
```

## Platform mode

For `~/code/fac-cra/`, prioritise meaningful verification over speed:
- relevant unit tests
- typecheck and lint
- relevant app build
- Playwright or end-to-end smoke tests
- browser checks for UI
- fixtures, mocks, or harness improvements when current tests are weak

If meaningful verification is not feasible and the change is risky, stop and ask rather than calling the work done.

