---
name: feature
description: Implement a feature using TDD. Works standalone (user describes what to build) or as part of the orchestrated pipeline (story and context provided). Handles complexity scaling, design, stubs, tests, implementation, migrations, refactoring, and review. Use when building a feature in an existing codebase.
---

# Feature

Implement a feature using test-driven development with complexity-appropriate workflow.

## Modes

This skill operates in two modes depending on how it's invoked:

### Standalone mode

When a user invokes this skill directly (e.g., `/feature`), the skill:
1. Captures the feature request
2. Surveys the codebase for patterns and conventions
3. Assesses complexity to choose the right workflow
4. Executes the appropriate workflow (direct or TDD cycle)

### Pipeline mode

When orchestrate invokes this skill for a story, context is already provided:
- Story ID, spec, design, standards, and branch are known
- Skip capture, survey, and complexity assessment
- Execute the TDD cycle directly from stubs onward
- Read configuration from manifest

## Standalone Workflow

### 1. Capture request

Gather minimal information:

**Required:**
- What to build (1-3 sentences)

**Optional (can be inferred):**
- Where it integrates (module, file, component)
- Constraints (performance, compatibility)
- Acceptance criteria

If the user hasn't provided enough detail, ask brief clarifying questions.

### 2. Survey codebase

Understand the project before writing code:

1. **Read project docs:** AGENTS.md or README for overview, documented patterns, testing approach
2. **Scan structure:** Relevant directories, related modules, architecture pattern
3. **Study existing patterns:** How similar features are implemented, naming, error handling, test patterns

### 3. Git setup

Before making code changes, ensure you're on a feature branch:

- If on `main`/`master`: create a feature branch using `commit branch`
- If already on a feature branch: proceed
- For solo projects committing directly to main: skip this step

### 4. Assess complexity

| Size | Criteria | Workflow |
|------|----------|----------|
| **S** | Single file, <50 lines, isolated | Direct implementation |
| **M** | 2-5 files, clear scope, follows patterns | TDD cycle with lightweight design |
| **L** | 5+ files, new patterns, architectural impact | TDD cycle with full design + review |

### 5. Execute workflow

#### Small (S) — Direct implementation

```
implement + test → quick review → commit
```

- Write implementation and tests together
- Brief review focused on obvious issues
- Single commit: `feat(scope): description`
- No TDD ceremony needed

#### Medium (M) — TDD cycle with lightweight design

```
lightweight design → stubs → RED → GREEN → refactor → review → user-test → PR
```

- Quick design plan (not saved to `.sdlc/`)
- Follow the TDD cycle defined in [references/tdd-cycle.md](references/tdd-cycle.md)
- Three commits (red, green, refactor)
- Standard review
- User testing before PR (see `skills/user-test/SKILL.md`)

#### Large (L) — TDD cycle with full design + review

```
design → design-review → stubs → RED → GREEN → refactor → review → user-test → PR
```

- Full design document with design review checkpoint
- Follow the TDD cycle defined in [references/tdd-cycle.md](references/tdd-cycle.md)
- Three commits (red, green, refactor)
- Full review with fresh context
- User testing before PR (see `skills/user-test/SKILL.md`)

## Pipeline Workflow

When invoked by orchestrate with story context:

1. Read story spec, design, and standards from provided context
2. Execute the TDD cycle directly: stubs → RED → GREEN → refactor → review → user-test → PR
3. Follow all gate conditions, artifact flow, and commit strategy from [references/tdd-cycle.md](references/tdd-cycle.md)
4. Report artifacts and gate results back to orchestrate for manifest update

### Pipeline input

Expect from orchestrate:
- Story ID and acceptance criteria
- Design document (architecture, components, interfaces)
- Project standards (paradigm, patterns, naming)
- Branch (already created by `commit:branch`)
- Configuration from manifest

### Pipeline output

Report back to orchestrate:
- Files created/modified (stubs, tests, implementation, migrations)
- Gate results (red_verified, green_verified, refactor_verified, review_approved, user_test_passed)
- Review verdict and comments
- User test results (pass/fail per scenario)
- Commit SHAs for each of the three commits

## Configuration

When a manifest exists, read from it:

```yaml
feature_cycle:
  tdd:
    strict: true
    test_runner: "pytest"
  migrations:
    enabled: true
    framework: "alembic"
    require_rollback: true
  review:
    fresh_context: true
    require_human_approval: true
  commits:
    conventional: true
    sign: false
```

When no manifest exists, use sensible defaults:
- Detect test runner from project files (package.json, pyproject.toml, go.mod, etc.)
- Detect migration framework from project files if present
- Default to conventional commits
- Default to requiring human approval for review
- Default to fresh context for review

## Tips

- Start with understanding the codebase; don't assume patterns
- Match existing code style exactly
- Write tests for new functionality
- Keep changes focused on the requested feature
- If scope grows beyond initial estimate, reassess complexity
- When in doubt, ask a clarifying question rather than assume
- For standalone mode, S-size features should be fast and lightweight — don't over-engineer
