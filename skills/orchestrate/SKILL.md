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
commit:branch → spec → design → design-review → stubs → test → implement → refactor → code-review → commit:commit → user-test → commit:pr → commit:merge

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

1. **commit:branch** - Create feature branch following git strategy
2. **spec** - Define contracts, schemas, behaviours
3. **design** - Plan architecture and components
4. **design-review** - Validate design against standards (checkpoint)
5. **stubs** - Create interfaces and types (compiles, not implemented)
6. **test** - Write tests against stubs (expect 0% pass)
7. **implement** - Write code to pass tests (expect 100% pass)
8. **refactor** - Clean up while tests stay green
9. **code-review** - Check quality and standards (checkpoint)
10. **commit:commit** - Commit changes with conventional message
11. **user-test** - User manually tests the functionality (checkpoint)
12. **commit:pr** - Create pull request
13. **commit:merge** - Merge when approved

### Phase gates

Before advancing to next phase, verify:

| Phase | Gate condition |
|-------|----------------|
| stubs → test | Code compiles/type-checks |
| test → implement | Tests exist and fail as expected |
| implement → refactor | All tests pass |
| refactor → code-review | Tests still pass |
| code-review → commit | Review approved or issues resolved |

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
        spec: "path/to/spec.md"
        design: "path/to/design.md"
      decisions:
        - phase: "design"
          decision: "Using event sourcing"
          rationale: "Requirement R3 needs full history"
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

## Notes

- Keep context tight: each phase receives only what it needs
- Follow TDD flow: stubs → tests (red) → implement (green) → refactor
- Support both solo and parallel multi-agent execution
- Manifest is the source of truth for pipeline state
