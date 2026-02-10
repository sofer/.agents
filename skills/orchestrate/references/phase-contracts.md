# Phase contracts

Input and output specifications for each pipeline phase.

## Table of contents

1. [intent](#intent)
2. [requirements](#requirements)
3. [spec](#spec)
4. [design](#design)
5. [design-review](#design-review)
6. [stubs](#stubs)
7. [test](#test)
8. [implement](#implement)
9. [refactor](#refactor)
10. [code-review](#code-review)
11. [commit](#commit)
12. [deploy](#deploy)
13. [monitor](#monitor)

---

## intent

Clarify problem, goals, success criteria, and constraints.

### Input
- User's initial idea or problem description
- Any existing context (prior conversations, documents)

### Output
```yaml
intent:
  problem_statement: "Clear articulation of core problem"
  users:
    - persona: "Description of user type"
      needs: ["What they expect to achieve"]
  constraints:
    technical: []
    business: []
    timeline: ""
  success_criteria:
    - "Measurable outcome 1"
    - "Measurable outcome 2"
  coding_standards:
    paradigm: "functional | oop | mixed"
    patterns: ["Pattern names to follow"]
    forbidden: ["Patterns to avoid"]
    naming: "Naming convention description"
```

### Checkpoint
Post-intent: Present intent summary for approval before requirements.

---

## requirements

Transform intent into user stories with acceptance criteria.

### Input
- Intent output (problem, users, constraints, success criteria)

### Output
```yaml
backlog:
  - id: "US-001"
    title: "Short story title"
    description: "As a [user], I want [goal] so that [benefit]"
    acceptance_criteria:
      - "Given [context], when [action], then [result]"
    priority: 1  # Lower = higher priority
    estimate: "S | M | L | XL"
    dependencies: []  # List of story IDs
```

### Notes
- Stories should be independent where possible
- Each story should be testable via acceptance criteria
- Prioritise by user value and dependencies

---

## spec

Define contracts, schemas, and behaviours for one story.

### Input
- Story ID and details from backlog
- Intent output (for context)
- Project standards

### Output
```yaml
spec:
  story_id: "US-001"
  contracts:
    - name: "ContractName"
      type: "api | event | data"
      definition: |
        # Schema or interface definition
  behaviours:
    - scenario: "Scenario name"
      given: "Initial state"
      when: "Action taken"
      then: "Expected outcome"
  data_schemas:
    - name: "SchemaName"
      fields:
        - name: "fieldName"
          type: "type"
          required: true
  edge_cases:
    - "Edge case description and expected handling"
```

### Output file
`.sdlc/stories/{story-id}/spec.md`

---

## design

Plan architecture and components for one story.

### Input
- Spec output (contracts, behaviours, schemas)
- Project standards (paradigm, patterns, naming)
- Existing codebase structure (if applicable)

### Output
```yaml
design:
  story_id: "US-001"
  architecture:
    pattern: "Pattern name (e.g., hexagonal, layered)"
    rationale: "Why this pattern fits"
  components:
    - name: "ComponentName"
      responsibility: "Single responsibility description"
      location: "path/to/component"
      dependencies: ["Other components"]
  interfaces:
    - name: "InterfaceName"
      methods:
        - signature: "methodName(params): returnType"
          purpose: "What it does"
  data_flow:
    - step: 1
      description: "Data enters via..."
    - step: 2
      description: "Processed by..."
  decisions:
    - decision: "Choice made"
      rationale: "Why this choice"
      alternatives: ["Other options considered"]
```

### Output file
`.sdlc/stories/{story-id}/design.md`

---

## design-review

Validate design before implementation.

### Input
- Design output
- Spec output
- Project standards

### Output
```yaml
design_review:
  story_id: "US-001"
  status: "approved | changes_requested | rejected"
  checklist:
    - item: "Follows project patterns"
      status: "pass | fail"
      notes: ""
    - item: "Handles all edge cases from spec"
      status: "pass | fail"
      notes: ""
    - item: "Components have single responsibility"
      status: "pass | fail"
      notes: ""
    - item: "No forbidden patterns used"
      status: "pass | fail"
      notes: ""
  issues:
    - severity: "blocker | major | minor"
      description: "Issue description"
      suggestion: "How to fix"
  approval_notes: "Summary of review outcome"
```

### Checkpoint
Post-design-review: Must be approved before proceeding to stubs.

---

## stubs

Create interfaces, signatures, and types. Code should compile but not be implemented.

### Input
- Design output (components, interfaces)
- Project standards (language, naming)

### Output
- Interface/type definitions in appropriate project locations
- Stub implementations that compile but throw/return placeholder values

```yaml
stubs:
  story_id: "US-001"
  files_created:
    - path: "src/interfaces/UserService.ts"
      type: "interface"
    - path: "src/types/User.ts"
      type: "type"
    - path: "src/services/UserServiceImpl.ts"
      type: "stub"
  compilation_status: "pass | fail"
  notes: ""
```

### Gate
Code must compile/type-check before proceeding to test.

---

## test

Write tests against stubs. Tests should fail initially (red).

### Input
- Stubs output (interfaces, types)
- Spec output (behaviours, edge cases)

### Output
- Test files in appropriate project test directory
- Tests should be runnable and fail (0% pass expected)

```yaml
test:
  story_id: "US-001"
  files_created:
    - path: "tests/services/UserService.test.ts"
      test_count: 5
  coverage:
    behaviours_covered: ["Scenario 1", "Scenario 2"]
    edge_cases_covered: ["Edge case 1"]
  run_result:
    total: 5
    passed: 0
    failed: 5
    status: "red"  # Expected
```

### Gate
Tests must exist and fail as expected before proceeding to implement.

---

## implement

Write code to pass all tests (green).

### Input
- Stubs output (interfaces to implement)
- Test output (tests to pass)
- Design output (architecture guidance)
- Database migration config (if migrations are enabled)

### Output
- Implementation files
- All tests passing

```yaml
implement:
  story_id: "US-001"
  files_modified:
    - path: "src/services/UserServiceImpl.ts"
      changes: "Full implementation"
  run_result:
    total: 5
    passed: 5
    failed: 0
    status: "green"  # Required
  migrations:
    created: true  # or false
    files:
      - path: "migrations/20240115_add_users_table.sql"
        direction: "up"
      - path: "migrations/20240115_add_users_table_down.sql"
        direction: "down"
    dev_db_verified: true
  notes: ""
```

### Note

If the feature requires database schema changes, the implement phase is responsible for:
- Creating migration files (both up and down)
- Applying migration to dev database
- Verifying schema after migration
- Recording migration files in story artifacts

Migration files are later validated by code-review and applied to production by deploy.

### Gate
All tests must pass (100%) before proceeding to refactor.

---

## refactor

Clean up code while keeping tests green.

### Input
- Implementation files
- Test suite (must stay passing)
- Project standards

### Output
- Refactored code
- Tests still passing

```yaml
refactor:
  story_id: "US-001"
  changes:
    - type: "extract_method | rename | simplify | remove_duplication"
      description: "What was refactored"
      files: ["affected files"]
  run_result:
    total: 5
    passed: 5
    failed: 0
    status: "green"  # Required
  decisions:
    - decision: "Extracted validation logic"
      rationale: "Improved testability and reuse"
```

### Gate
Tests must still pass before proceeding to code-review.

---

## code-review

Check quality, security, and standards compliance.

### Input
- All implementation files for the story
- Design output (to verify adherence)
- Spec output (to verify completeness)
- Project standards

### Output
```yaml
code_review:
  story_id: "US-001"
  status: "approved | changes_requested | rejected"
  checklist:
    - item: "Follows design patterns"
      status: "pass | fail"
    - item: "No security vulnerabilities"
      status: "pass | fail"
    - item: "Code is readable and maintainable"
      status: "pass | fail"
    - item: "Error handling is appropriate"
      status: "pass | fail"
    - item: "No forbidden patterns"
      status: "pass | fail"
  issues:
    - severity: "blocker | major | minor"
      file: "path/to/file"
      line: 42
      description: "Issue description"
      suggestion: "How to fix"
  approval_notes: ""
```

### Checkpoint
Post-code-review: Must be approved before committing.

### Note

When invoked as part of the story cycle pipeline, code-review should run with fresh context:
- Receives: diff since branch point, spec/acceptance criteria, coding standards
- Does NOT receive: implementation conversation history
- This creates genuine "second reviewer" behaviour

If migrations exist in the story artifacts, code-review should also assess:
- Migration safety (reversible, no data loss)
- Migration correctness (schema matches implementation expectations)
- Rollback migration exists and is valid

---

## commit

Git operations: branch, commit, PR, merge.

### Subcommands

#### commit:branch
Create feature branch.

**Input:**
- Story ID and slug
- Git strategy from config

**Output:**
- Branch created following pattern (e.g., `story/US-001-user-login`)

#### commit:commit
Commit staged changes.

**Input:**
- Changed files
- Story context

**Output:**
- Commit with conventional message (e.g., `feat(auth): implement user login`)

#### commit:pr
Create pull request.

**Input:**
- Branch name
- Story details
- Summary of changes

**Output:**
- PR created with description linking to story

#### commit:merge
Merge PR (when approved).

**Input:**
- PR reference
- Merge strategy (squash, merge, rebase)

**Output:**
- PR merged, branch cleaned up

### Story cycle commit strategy

When used within the orchestrated story cycle, commit is invoked three times per story:

1. After RED phase: `feat(story-id): define interface and test cases`
   - Includes: stub files + test files
2. After GREEN phase: `feat(story-id): implement to pass tests`
   - Includes: implementation files + migration files (if any)
3. After REFACTOR phase: `refactor(story-id): improve structure`
   - Includes: refactored files only

Each commit uses `commit:commit` subcommand. The orchestrator provides the commit message.

---

## deploy

Ship to target environment.

### Input
- Build artifacts
- Deployment configuration
- Target environment
- Migration files from story artifacts (if any)

### Output
```yaml
deploy:
  version: "1.2.3"
  environment: "staging | production"
  status: "success | failed | rolled_back"
  url: "https://deployed-url.example.com"
  artifacts:
    - name: "artifact-name"
      location: "registry/path"
  migrations:
    applied: true
    files: ["migrations/20240115_add_users_table.sql"]
    verified: true
    rollback_tested: true
  notes: ""
```

### Database migrations (if applicable)

1. Validate migration files (dry-run against production-like environment)
2. Present migration plan to user for approval (human-in-the-loop required)
3. Apply migrations to production
4. Verify schema post-migration
5. If migration fails: execute rollback migration, halt deployment

Production migration approval is always a human-in-the-loop checkpoint.

---

## monitor

Observe health and gather feedback.

### Input
- Deployed application
- Success criteria from intent
- Monitoring configuration

### Output
```yaml
monitor:
  status: "healthy | degraded | unhealthy"
  metrics:
    - name: "metric_name"
      value: 123
      threshold: 100
      status: "ok | warning | critical"
  feedback:
    - source: "user | system | log"
      description: "Feedback item"
      action: "Add to backlog | Investigate | Ignore"
  backlog_additions:
    - title: "New story from feedback"
      source: "monitor"
      priority: 2
```

### Notes
Feedback may generate new backlog items, creating a continuous improvement loop.
