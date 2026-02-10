---
name: orchestrate
description: Coordinate full SDLC pipeline for software projects. Manages backlog, spawns phase agents with minimal context, gates transitions, and handles checkpoints. Use when starting a new project, picking up the next story, or resuming pipeline work.
---

# SDLC Orchestration

Coordinate the full software development lifecycle through a structured pipeline of specialised agents.

## Pipeline overview

```
[Project init]
intent → requirements (produces backlog)

[Story cycle - iterative per story]
commit:branch → spec → design → design-review → stubs → test → commit:commit(red) → implement → commit:commit(green) → refactor → code-review → commit:commit(refactor) → user-test → commit:pr → commit:merge

[Release]
deploy → monitor (feedback → backlog)
```

## Manifest location

Store manifest at `.sdlc/manifest.yaml` in the project root. Create the directory if it does not exist.

## Core responsibilities

1. **Initialise project** - Gather config, run intent, build initial backlog
2. **Pick next story** - Select highest priority story from backlog
3. **Run story cycle** - Execute phases in sequence with gates
4. **Spawn agents** - Launch phase skills with minimal context
5. **Gate transitions** - Enforce prerequisites before advancing
6. **Handle failures** - Retry, rollback, or escalate as appropriate
7. **Pause at checkpoints** - Await human approval at configured points
8. **Log decisions** - Record choices and rationale to manifest
9. **Enforce gate conditions** - Do not advance to next phase if gate condition fails; follow rollback handling in `skills/feature/references/tdd-cycle.md`
10. **Track gate results** - Record gate pass/fail in manifest per story
11. **Fresh context for review** - Spawn code-review with a new agent invocation receiving only the diff, spec, and standards (not the implementation conversation)
12. **Pass artifacts by reference** - Between skills, pass file paths and summary documents, not full file contents

## Commands

The user may invoke orchestration with these patterns:

- `start project` / `init` - Begin new project setup
- `next story` / `continue` - Pick and start next story from backlog
- `resume` - Continue from current phase
- `status` - Show manifest state and progress
- `checkpoint` - Present decision summary for approval

## Project initialisation

When starting a new project:

1. Check for existing `.sdlc/manifest.yaml`
2. If manifest exists with incomplete init:
   - Detect current init phase from `init_phase` field
   - Offer to resume from that point or reinitialise
3. If manifest exists with complete init, offer to resume or reinitialise
4. If no manifest:
   - Ask for project name
   - Create manifest with project name and `init_phase: name_collected`
   - Run `intent` skill to clarify goals
   - Update manifest with intent output and `init_phase: intent_complete`
   - Gather remaining technical config (language, runtime, git, run commands)
     - Use intent's `coding_standards` as defaults for paradigm/patterns/naming
   - Update manifest with full config and `init_phase: config_complete`
   - Run `requirements` skill to build backlog

### Default configuration

```yaml
project:
  name: ""
  standards:
    paradigm: "mixed"
    language: ""
    runtime: ""  # e.g., "Bun", "Node", "Python"
    patterns: []
    forbidden: []
    naming: ""
  git:
    strategy: "feature-branch"
    pattern: "story/{id}-{slug}"
    auto_pr: true
  run:  # How to execute the project locally
    command: ""  # e.g., "./brain", "npm start", "python main.py"
    test: ""     # e.g., "bun test", "npm test", "pytest"
  checkpoints:
    - "post-intent"
    - "post-design-review"
    - "post-code-review"
    - "post-commit"  # User tests before next story
```

**Note:** The `standards.paradigm`, `standards.patterns`, `standards.forbidden`, and `standards.naming` fields may be populated from intent output's `coding_standards`. Only prompt for these if intent did not capture them.

## Story cycle execution

For each story:

1. **commit:branch** — Create feature branch
2. **spec** — Define contracts, schemas, behaviours
3. **design** — Plan architecture and components
4. **design-review** — Validate design (checkpoint)
5. **stubs** — Create interfaces and types
6. **test** — Write failing tests (RED)
7. **commit:commit(red)** — Commit stubs + tests: "feat(story-id): define interface and test cases"
8. **implement** — Write code to pass tests, create migrations if needed (GREEN)
9. **commit:commit(green)** — Commit implementation + migrations: "feat(story-id): implement to pass tests"
10. **refactor** — Clean up while tests stay green
11. **code-review** — Review with fresh context (checkpoint)
12. **commit:commit(refactor)** — Commit refactored code: "refactor(story-id): improve structure"
13. **user-test** — User manually tests functionality (checkpoint)
14. **commit:pr** — Create pull request
15. **commit:merge** — Merge when approved

For detailed TDD cycle execution (artifact flow, gate conditions, commit strategy,
migration handling, and rollback), see the feature skill's reference document at
`skills/feature/references/tdd-cycle.md`.

### Phase gates

Before advancing to next phase, verify:

| Phase | Gate condition | On failure |
|-------|----------------|------------|
| stubs → test | Code compiles/type-checks | Fix stubs |
| test → commit(red) | New tests fail, existing tests pass | Fix tests |
| commit(red) → implement | Red commit succeeds | Resolve git issues |
| implement → commit(green) | All tests pass (100%), dev DB verified if migrations | Continue implementing |
| commit(green) → refactor | Green commit succeeds | Resolve git issues |
| refactor → code-review | All tests still pass | Revert refactor, retry |
| code-review → commit(refactor) | Review approved or issues resolved | Loop to refactor with review comments |

### Spawning phase agents

Provide each agent with minimal context:

```
Run {phase} skill with context:
- Story: {story_id} - {story_title}
- Acceptance criteria: {criteria}
- Relevant artifacts: {list from manifest}
- Standards: {project.standards}
```

Only include artifacts from immediately preceding phases. Do not overload context.

## Checkpoints

At configured checkpoints:

1. Summarise decisions made since last checkpoint
2. Present current state and proposed next steps
3. Wait for explicit approval before continuing
4. Log approval/rejection to manifest

### Decision summary format

```
## Checkpoint: {phase}

### Decisions made
- [{phase}] {decision}: {rationale}
- ...

### Current state
- Story: {id} - {title}
- Phase: {current_phase}
- Branch: {branch_name}

### Next steps
1. {next_phase}: {what it will do}

Approve to continue? [y/n]
```

## User testing (post-commit checkpoint)

**IMPORTANT:** After committing a story, ALWAYS prompt the user to manually test the functionality before proceeding to the next story.

### Why this matters

- Automated tests verify code correctness, not usability
- Integration issues only surface when running the real system
- Config problems (API keys, credentials) are caught early
- User gains confidence the feature actually works

### User test prompt format

```
## Story complete: {id} - {title}

### What was implemented
- {brief summary of functionality}

### Test it now

{Provide specific commands or steps to test the feature}

Example:
```
./brain config
./brain config get anthropic.model
./brain config set anthropic.model claude-3-haiku
```

### Verify
- [ ] Feature works as expected
- [ ] No errors or unexpected behaviour

**Please test now.** Ready to continue to next story? [y/n]
```

### What to test

For each story type, suggest appropriate tests:

- **CLI commands**: Run the command with various inputs
- **API integrations**: Verify connection works with real credentials
- **Data storage**: Check data is persisted correctly
- **Background processes**: Start and verify it runs

### If testing reveals issues

1. Do NOT proceed to next story
2. Fix the issue in the current story
3. Re-run tests (automated and manual)
4. Re-prompt user to verify fix

## Failure handling

When a phase fails:

1. **Retry** - Attempt phase again with same context (max 2 retries)
2. **Rollback** - Revert to previous phase state if retry fails
3. **Escalate** - Pause for human intervention with failure details

Log all failures and recovery actions to manifest.

## Manifest management

Update manifest after each phase:

```yaml
manifest:
  project:
    name: "project-name"
    init_phase: "config_complete"  # name_collected | intent_complete | config_complete
    standards: {}
    # ... rest of config
  intent: {}            # Intent skill output
  backlog: []           # Prioritised story list
  current_story: null   # Active story ID
  stories:
    US-001:
      status: "in-progress"  # complete | in-progress | blocked
      phase: "design"        # Current phase
      branch: "story/US-001-user-login"
      artifacts:
        spec: ".sdlc/stories/US-001/spec.md"
        design: ".sdlc/stories/US-001/design.md"
        stubs: []           # file paths produced by stubs skill
        tests: []           # file paths produced by test skill
        implementation: []  # file paths produced by implement skill
        migrations: []      # migration file paths (if any)
        review_verdict: ""  # approved | changes_requested | blocked
      decisions:
        - phase: "design"
          decision: "Using event sourcing"
          rationale: "Requirement R3 needs full history"
      gate_results:
        red_verified: false      # new tests fail, existing pass
        green_verified: false    # all tests pass after implementation
        refactor_verified: false # all tests still pass after refactor
        review_approved: false   # review verdict is "approved"
  releases: []
```

### Artifact storage

Store phase outputs in `.sdlc/stories/{story-id}/`:
- `spec.md` - Specification
- `design.md` - Design document
- `stubs/` - Interface definitions
- `tests/` - Test files (may also live in project test directory)
- `review-notes.md` - Review feedback

## Phase contracts

See [references/phase-contracts.md](references/phase-contracts.md) for detailed input/output specifications for each phase.

## Integration with existing skills

- **intent** - Use as-is for project initialisation
- **commit** - Extend to support branch/commit/pr/merge subcommands
- **reconcile** - Use for drift detection and state synchronisation

## Drift detection

Before advancing to next phase or picking next story, check for divergence between manifest and reality.

### When to check for drift

1. **Before picking next story** - Ensure previous work is properly recorded
2. **At phase transitions** - Verify current phase is accurate before advancing
3. **When resuming after pause** - Catch any manual changes made outside the pipeline
4. **On explicit `status` command** - Include drift warnings in status output

### Detection triggers

Check for these conditions:

```
1. Uncommitted files matching current story scope
2. Branch doesn't match expected pattern for current_story
3. Manifest phase contradicts file state (e.g., "design" but implementation exists)
4. Stale branches from completed stories
5. Artifacts referenced in manifest that don't exist
```

### Integration workflow

```
[Pipeline action requested]
       │
       ▼
[Check for drift]
       │
       ├── No drift → Continue pipeline
       │
       └── Drift detected
              │
              ▼
       [Pause pipeline]
              │
              ▼
       [Invoke /reconcile --report]
              │
              ▼
       [Present findings to user]
              │
              ▼
       [Offer choices]
              │
              ├── Apply corrections → Run reconcile
              │
              ├── Continue anyway → Resume pipeline
              │
              └── Abort → Stop and investigate
```

### Example drift handling

When drift is detected before picking next story:

```markdown
## Drift detected

Before picking the next story, reconciliation found issues:

### Divergences

- **Phase drift** (US-004): Manifest says "design", but implementation files exist
- **Uncommitted files**: scoring.py, triage.py, writeback.py
- **Stale branch**: story/US-003-match-gmail-correspondence (merged)

### Options

1. **Reconcile first** - Fix divergences before continuing
2. **Continue anyway** - Pick next story despite drift
3. **Investigate** - Pause to manually review state

Which would you like to do?
```

### Severity thresholds

| Severity | Action |
|----------|--------|
| High (uncommitted implementation, status mismatch) | Block pipeline, require reconcile |
| Medium (phase drift, branch mismatch) | Warn, offer to reconcile |
| Low (stale branches, orphan artifacts) | Note in status, continue |

## Notes

- Keep context tight: each phase receives only what it needs
- Follow TDD flow: stubs → tests (red) → implement (green) → refactor
- Support both solo and parallel multi-agent execution
- Manifest is the source of truth for pipeline state
