---
name: decompose
description: Break a clear goal, plan, or project into independently executable pieces with dependencies and verification criteria. Use when work is too large for one coherent implementation slice or when delegation needs clean ownership boundaries.
---

# Decompose

## Purpose

Turn a known goal into executable pieces that can be sequenced, delegated, verified, and recombined.

Use this after the problem and constraints are clear. If they are not clear, use `problem-statement` or `constrain` first.

## Process

1. Identify the natural boundaries:
   - deliverables
   - audiences
   - system boundaries
   - ownership areas
   - handoff points
2. Map dependencies for each piece:
   - required inputs
   - produced outputs
   - blockers
   - what can run in parallel
3. Classify each piece:
   - `routine`: clear work, suitable for delegation
   - `judgement`: needs human decision points
   - `discovery`: approach is not known yet
   - `external`: blocked on outside input or approval
4. Define done for each piece.
5. Identify the critical path and parallel opportunities.

## Output

```markdown
## Execution plan

### Phase 1: [Name]

#### Task 1.1: [Name]
- Type: routine | judgement | discovery | external
- What: [One sentence]
- Depends on: [Dependencies or none]
- Produces: [Output]
- Done when: [Verifiable criteria]
- Owner: [If known]

## Critical path
[Tasks where delay delays the whole project.]

## Parallel opportunities
[Tasks that can be done independently.]

## Checkpoints
[Where the user should review or decide.]
```

## Rules

- Do not decompose vague work. Clarify first.
- Prefer fewer, meaningful pieces over a long task list.
- Delegated pieces must have clear ownership and verification.
- For platform work, keep Distribution and Partners boundaries explicit.

