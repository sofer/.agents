---
name: code-review
description: Review implementation for quality, security, and standards compliance. Use after refactor phase to validate code before committing. Gates progression to commit phase.
---

# Code review

Review the implemented code for quality, security, and standards compliance before committing.

## Purpose

Code review validates that implementation:
- Meets spec requirements
- Follows design architecture
- Adheres to project standards
- Contains no security vulnerabilities
- Is maintainable and readable

## Pipeline context isolation

When invoked as part of the orchestrated story cycle, this skill should run with **fresh context** — a new agent invocation that receives:

- Diff since branch point (not the full implementation files)
- Spec/acceptance criteria
- Coding standards

It should NOT receive the implementation conversation history. This creates genuine "second reviewer" behaviour where the reviewer assesses the code without the implementer's assumptions.

## Input

Expect from orchestrator:
- Implementation files from refactor phase
- Spec output (to verify completeness)
- Design output (to verify adherence)
- Project standards (patterns, naming, style)
- Test results (must be passing)

## Review dimensions

### 1. Spec compliance

Verify implementation meets all requirements:

```yaml
spec_compliance:
  - requirement: "User can register with email and name"
    status: "pass | fail"
    evidence: "createUser endpoint implemented in UserController"
    notes: ""

  - requirement: "Duplicate emails are rejected"
    status: "pass | fail"
    evidence: "DuplicateEmailError thrown in UserService"
    notes: ""

  - requirement: "Email is normalised to lowercase"
    status: "pass | fail"
    evidence: "normaliseEmail() called before save"
    notes: ""
```

### 2. Design adherence

Verify implementation follows the design:

```yaml
design_adherence:
  - item: "Uses layered architecture"
    status: "pass | fail"
    notes: "Controller → Service → Repository correctly implemented"

  - item: "Dependencies injected via constructor"
    status: "pass | fail"
    notes: ""

  - item: "Error handling follows strategy"
    status: "pass | fail"
    notes: "Domain errors propagate correctly to controller"

  - item: "Data flow matches design"
    status: "pass | fail"
    notes: ""
```

### 3. Code quality

Assess code craftsmanship:

```yaml
code_quality:
  - item: "Readable and well-structured"
    status: "pass | fail"
    notes: ""

  - item: "No unnecessary complexity"
    status: "pass | fail"
    notes: ""

  - item: "Appropriate error handling"
    status: "pass | fail"
    notes: ""

  - item: "No code smells"
    status: "pass | fail"
    notes: ""

  - item: "Follows naming conventions"
    status: "pass | fail"
    notes: ""

  - item: "No dead code or commented code"
    status: "pass | fail"
    notes: ""
```

### 4. Security

Check for security issues:

```yaml
security:
  - item: "Input validation"
    status: "pass | fail"
    notes: "Email and name validated before use"

  - item: "No injection vulnerabilities"
    status: "pass | fail"
    notes: "Parameterised queries used"

  - item: "Sensitive data handling"
    status: "pass | fail"
    notes: "No passwords logged, no PII in errors"

  - item: "Authentication/authorisation"
    status: "pass | fail | n/a"
    notes: ""

  - item: "No hardcoded secrets"
    status: "pass | fail"
    notes: ""
```

### 5. Standards compliance

Verify adherence to project standards:

```yaml
standards:
  - item: "Follows prescribed paradigm"
    status: "pass | fail"
    notes: ""

  - item: "Uses approved patterns"
    status: "pass | fail"
    notes: ""

  - item: "Avoids forbidden patterns"
    status: "pass | fail"
    notes: ""

  - item: "Naming conventions followed"
    status: "pass | fail"
    notes: ""

  - item: "Consistent code style"
    status: "pass | fail"
    notes: ""
```

### 6. Test coverage

Verify test quality:

```yaml
test_coverage:
  - item: "All behaviours tested"
    status: "pass | fail"
    notes: ""

  - item: "Edge cases covered"
    status: "pass | fail"
    notes: ""

  - item: "Error paths tested"
    status: "pass | fail"
    notes: ""

  - item: "Tests are maintainable"
    status: "pass | fail"
    notes: ""
```

### 7. Runnability (CLI projects)

Verify users can execute the code from the project directory:

```yaml
runnability:
  - item: "Executable entry point exists"
    status: "pass | fail | n/a"
    notes: "Shell wrapper at ./brain is executable"

  - item: "Entry point runs without errors"
    status: "pass | fail | n/a"
    notes: "Running ./brain --help shows usage"

  - item: "Run command documented"
    status: "pass | fail | n/a"
    notes: "AGENTS.md includes how to run locally"
```

**Why this matters:**
- Users must be able to test each story from the terminal before moving to the next
- A story is not complete if users cannot exercise the functionality
- Catches missing executable permissions, missing shebangs, path issues

### 8. Migration safety (if applicable)

```yaml
migration_safety:
  - item: "Migration is reversible"
    status: "pass | fail | n/a"
    notes: ""

  - item: "Rollback migration exists"
    status: "pass | fail | n/a"
    notes: ""

  - item: "No data loss in migration"
    status: "pass | fail | n/a"
    notes: ""

  - item: "Migration is idempotent or guarded"
    status: "pass | fail | n/a"
    notes: ""
```

## Review process

1. **Load context**: Read implementation, spec, design, standards
2. **Run checks**: Go through each dimension systematically
3. **Document findings**: Record issues with specific locations
4. **Determine verdict**: Approve, request changes, or reject
5. **Provide feedback**: Explain issues with suggestions

## Issue classification

- **Blocker**: Must fix (security flaw, spec violation, broken functionality)
- **Major**: Should fix (significant quality issue, standards violation)
- **Minor**: Nice to fix (style preference, minor improvement)
- **Suggestion**: Optional enhancement

## Output

```yaml
code_review:
  story_id: "US-001"
  status: "approved | changes_requested | rejected"

  summary:
    spec_compliance: "3/3 passed"
    design_adherence: "4/4 passed"
    code_quality: "5/6 passed"
    security: "5/5 passed"
    standards: "4/5 passed"
    test_coverage: "4/4 passed"
    runnability: "3/3 passed"  # For CLI projects
    migration_safety: "4/4 passed"  # If applicable

  issues:
    - severity: "major"
      category: "code_quality"
      file: "src/services/user.service.ts"
      line: 42
      description: "Error message exposes internal details"
      current: "throw new Error(`Database error: ${err.message}`)"
      suggestion: "Log internal error, throw generic user-facing error"

    - severity: "minor"
      category: "standards"
      file: "src/controllers/user.controller.ts"
      line: 15
      description: "Method name doesn't follow convention"
      current: "CreateUser"
      suggestion: "Rename to 'createUser' (camelCase)"

  verdict:
    decision: "changes_requested"
    rationale: "One major security concern needs addressing"
    blocking_issues: 1
    total_issues: 2

  positive_notes:
    - "Clean separation of concerns"
    - "Comprehensive error handling"
    - "Well-tested edge cases"
    - "Clear naming throughout"

  approval_conditions:
    - "Fix error message exposure issue"
```

## Feedback format

```markdown
## Code review: Changes requested

### Issues to address

**[Major] Error message exposes internal details**
📍 `src/services/user.service.ts:42`

The current error handling exposes database internals to the client:
```typescript
throw new Error(`Database error: ${err.message}`)
```

*Suggestion*: Log the full error internally, throw a generic error to client:
```typescript
this.logger.error('Database error', { error: err, userId: user.id });
throw new ServiceError('Unable to save user');
```

---

**[Minor] Method naming convention**
📍 `src/controllers/user.controller.ts:15`

Method `CreateUser` should be `createUser` per project conventions.

---

### What's working well
- Clean layered architecture
- Comprehensive test coverage
- Good use of dependency injection
- Clear data flow

### Next steps
Please address the major issue and resubmit for review.
```

## Checkpoint behaviour

This phase is a configured checkpoint. After review:

1. Present decision summary to user
2. If approved: Proceed to commit phase
3. If changes requested: Return to implement/refactor with feedback
4. If rejected: Escalate for discussion

## Verdict criteria

**Approved**: No blockers, no major issues
**Changes requested**: Has major issues requiring fixes
**Rejected**: Fundamental problems requiring redesign

## Standalone usage

When used outside the orchestrated pipeline (e.g., via `/review`), code-review can work without spec/design documents:

**What to skip:**
- Spec compliance checks (no spec to compare against)
- Design adherence checks (no design document)

**What to focus on:**
- Code quality (readability, complexity, error handling)
- Security (input validation, no secrets, injection risks)
- Standards (naming, patterns, consistency with codebase)
- Test coverage (tests exist, tests pass)
- Runnability (for CLI projects)

**Inferring requirements:**
- Read PR description or commit messages
- Examine code comments and docstrings
- Ask user directly if intent is unclear

**Standalone input:**
```yaml
review_request:
  type: "branch"  # or pr, commits, files
  reference: "feature/add-logout"
  intent: "Add logout functionality"  # optional, can be inferred
```

**Standalone output:**
Same format as standard output, but with spec_compliance and design_adherence sections omitted or marked as "n/a - standalone review".

## Tips

- Review objectively; focus on code, not coder
- Provide actionable feedback with examples
- Acknowledge good practices, not just problems
- If implementation is correct but design was flawed, note for future
- Security issues are always blockers
- Be thorough but proportional to change size
