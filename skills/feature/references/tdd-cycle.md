# TDD Cycle

Detailed execution guide for one pass of the test-driven development cycle within the feature skill. This document is referenced by both the feature skill (standalone M/L features) and the orchestrate skill (pipeline story cycle).

## Artifact Flow

Each skill produces artifacts that downstream skills consume. Pass file paths and summary documents, not full file contents.

| Skill | Consumes | Produces |
|-------|----------|----------|
| `stubs` | Design doc, coding standards | Stub files (on disk) |
| `test` | Stub files, spec/acceptance criteria | Test files (on disk) |
| `implement` | Stub files, test files, migration config | Implementation files, migration files (if needed) |
| `refactor` | Implementation files, test files, coding standards | Refactored files (on disk) |
| `code-review` | Diff since branch point, spec, coding standards | Review verdict + comments |

## Step-by-Step Execution

### 1. Create stubs

**Skill:** `stubs`

Create function signatures, types, interfaces. Bodies throw `NotImplemented` or return placeholder values. Must compile/parse without errors.

**Gate:** Files compile/type-check successfully.

### 2. Write failing tests (RED)

**Skill:** `test`

Write tests that describe desired behaviour against the stubs. Tests target acceptance criteria from the spec (pipeline) or feature request (standalone).

**Gate:**
- All new tests fail (0% pass on new tests)
- Existing tests still pass (no regressions)

**Commit:** stubs + test files → `feat(story-id): define interface and test cases`

### 3. Implement + migrate (GREEN)

**Skill:** `implement`

Write minimal code to make tests pass. If the feature requires schema changes: create migration (up + down), apply to dev DB, verify schema.

**Gate:**
- All tests pass (100%)
- If migrations exist: dev DB schema verified
- No skipped or pending tests

**Commit:** implementation + migration files → `feat(story-id): implement to pass tests`

### 4. Refactor

**Skill:** `refactor`

Improve structure, naming, duplication. No behaviour changes.

**Gate:** All tests still pass (100%).

### 5. Review (fresh context)

**Skill:** `code-review`

Spawn a fresh agent invocation receiving only:
- Diff since branch point
- Spec/acceptance criteria
- Coding standards

Does NOT receive implementation conversation history. Assess code quality, standards, security, test coverage. If migrations exist, assess migration safety.

**Gate:** Review approved (human or agent verdict).

**Commit:** refactored files → `refactor(story-id): improve structure`

### 6. Prepare PR

**Skill:** `commit:pr`

Generate PR description from spec + diff. List migrations with rollback instructions if any. Confirm all tests passing and review approved.

**Human-in-the-loop:** Required.

## Commit Strategy

Three meaningful commits per cycle:

1. **After RED**: stubs + failing tests → `feat(story-id): define interface and test cases`
2. **After GREEN**: implementation + migrations → `feat(story-id): implement to pass tests`
3. **After REFACTOR**: cleanup → `refactor(story-id): improve structure`

For standalone mode without a story ID, use a descriptive scope instead: `feat(auth): define interface and test cases`.

## Gate Conditions Reference

| After Step | Condition | On Failure |
|------------|-----------|------------|
| stubs | Files compile/type-check | Fix stubs |
| test (RED) | New tests fail, existing pass | Fix tests |
| implement (GREEN) | All tests pass, dev DB verified if migrations | Continue implementing |
| refactor | All tests still pass | `git checkout` refactored files, retry |
| code-review | Verdict is "approved" | Loop to refactor with review comments |
| commit:pr | Tests pass, review approved | Block PR |

## Migration Handling

Migrations are implementation detail handled within the `implement` skill:

1. Create migration file (up + down) using project's framework
2. Apply to dev database
3. Verify schema
4. Record migration files in artifacts

Production migrations are handled by the `deploy` skill during release, NOT during feature development.

## Rollback Handling

| Scenario | Action |
|----------|--------|
| GREEN fails after dev migration | Roll back migration, fix implementation, re-migrate |
| Refactor breaks tests | `git checkout` refactored files, retry |
| Review requests changes | Return to refactor with review comments as input |
| PR blocked | Address issues, re-run from relevant step |

## Scope

This covers one pass of the TDD cycle for one feature or behaviour slice. For multi-story features, the orchestrator loops the feature skill per story.

## What This Cycle Does NOT Do

- **Production migrations** — belong in `deploy`
- **Merge** — handled by `commit:merge` after PR approval
- **Story selection or backlog management** — handled by `orchestrate`
- **Intent or requirements gathering** — handled by `intent` and `requirements`
