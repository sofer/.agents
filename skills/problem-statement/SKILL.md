---
name: problem-statement
description: Turn a vague or underspecified request into a self-contained problem statement. Use when the user has a rough idea, when a request would fail if handed directly to an agent, or before non-trivial work that needs shared understanding.
---

# Problem statement

## Purpose

Create a clear, portable statement of the problem before planning or implementation.

## Process

1. Take the user's request as given.
2. Identify the gaps that matter:
   - missing context
   - ambiguous terms
   - unstated assumptions
   - audience or user
   - success criteria
   - constraints and non-goals
   - risks or failure modes
3. Infer safe details from context when the inference is low-risk.
4. Ask only questions where guessing would affect correctness, scope, risk, ownership, or verification.
5. Rewrite the request as a self-contained problem statement.

## Output

Produce:

```markdown
## Problem statement
[One paragraph to half a page that someone could understand without the prior conversation.]

## Assumptions
- [What was inferred and why]

## Open questions
- [Only questions that still affect execution]

## Risks
- [Ways the work could be technically correct but wrong]
```

For small tasks, keep the output shorter and use chat as the record. For non-trivial work, this can become the basis for a lightweight plan or spec.

