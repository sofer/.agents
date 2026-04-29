---
name: constrain
description: Define guardrails for significant work before delegating or implementing it. Use when failure modes, ownership boundaries, platform safety, or technically-correct-but-wrong outcomes matter.
---

# Constrain

## Purpose

Make implicit judgement explicit before work is handed to an agent, person, or automated process.

## Process

1. Clarify the task, executor, audience, and success criteria.
2. Surface failure modes:
   - If someone optimised only for the stated goal, what collateral damage could they cause?
   - If an agent followed the request literally, what reasonable bad outcome could result?
   - What context does the user have that the executor does not?
   - Where might two good priorities conflict?
3. Convert the answers into constraints.
4. Validate the constraints with the user before execution when the work is high-risk.

## Output

```markdown
## Must
[Hard requirements. If these fail, the work fails.]

## Must not
[Specific prohibitions, each tied to a plausible failure mode.]

## Prefer
[Decision rules for tradeoffs.]

## Escalate when
[Specific stop-and-ask conditions.]
```

## Rules

- Every `must not` should prevent a real plausible failure mode.
- `Prefer` items are tradeoff rules, not aspirations.
- Escalation triggers must be observable. Avoid vague triggers like "when unsure".
- Keep the constraint set as small as possible while covering the important risks.

