---
name: code-review
description: Review code for quality, security, and standards compliance. Works as a pipeline gate after refactor phase, or standalone against PR URLs, branch names, commit ranges, or file lists.
---

# Code review

Review code for quality, security, and standards compliance. Works within the orchestrated SDLC pipeline (after refactor, before commit) or standalone against any existing changes.

## Purpose

Code review validates that implementation:
- Meets spec requirements (pipeline mode)
- Follows design architecture (pipeline mode)
- Adheres to project standards
- Contains no security vulnerabilities
- Is maintainable and readable
- Has adequate test coverage

## Pipeline context isolation

When invoked as part of the orchestrated story cycle, this skill should run with **fresh context** — a new agent invocation that receives:

- Diff since branch point (not the full implementation files)
- Spec/acceptance criteria
- Coding standards

It should NOT receive the implementation conversation history. This creates genuine "second reviewer" behaviour where the reviewer assesses the code without the implementer's assumptions.

## Input

### Pipeline input

Expect from orchestrator:
- Implementation files from refactor phase
- Spec output (to verify completeness)
- Design output (to verify adherence)
- Project standards (patterns, naming, style)
- Test results (must be passing)

### Standalone input

Accept any of:
- PR URL: `https://github.com/owner/repo/pull/123`
- Branch name: `feature/add-logout`
- Commit range: `main..feature/add-logout` or `abc123..def456`
- File list: `src/auth.ts src/login.tsx`

```yaml
review_request:
  scope_type: "branch"  # pr | branch | commits | files
  reference: "feature/add-logout"
  focus: ""  # optional: specific areas to focus on
  intent: "Add logout functionality"  # optional, can be inferred
```

## Standalone workflow

```
identify scope → understand intent → survey changes → verify → assess quality → provide feedback
```

### 1. Identify scope

Determine what code to review:

**For PR:**
```bash
gh pr view 123 --json files,additions,deletions,body,title
gh pr diff 123
```

**For branch:**
```bash
git log main..feature/add-logout --oneline
git diff main..feature/add-logout --stat
git diff main..feature/add-logout
```

**For commits:**
```bash
git show abc123..def456 --stat
git diff abc123..def456
```

**For files:**
```bash
git diff HEAD -- src/auth.ts src/login.tsx
```

```yaml
scope:
  scope_type: "branch"
  reference: "feature/add-logout"
  base: "main"
  files_changed: 5
  lines_added: 127
  lines_removed: 23
  files:
    - "src/store/authSlice.ts"
    - "src/hooks/useAuth.ts"
    - "src/components/UserMenu.tsx"
    - "src/components/UserMenu.test.tsx"
    - "src/types/auth.ts"
```

### 2. Understand intent

Determine what the change is supposed to accomplish:

**Sources (in priority order):**
1. PR description or title
2. Commit messages
3. Code comments
4. Direct question to user

```yaml
intent:
  description: "Add logout functionality to the user menu"
  source: "commit_messages"
  goals:
    - "Allow users to log out from any page"
    - "Clear session state on logout"
    - "Redirect to login page after logout"
```

If intent is unclear, ask:
> What is this change supposed to accomplish?

### 3. Survey changes

For each changed file, understand what changed and why:

```yaml
changes_summary:
  - file: "src/store/authSlice.ts"
    scope_type: "modified"
    purpose: "Add logout action to clear auth state"
    key_changes:
      - "Added logout reducer"
      - "Added clearTokens helper"

  - file: "src/hooks/useAuth.ts"
    scope_type: "modified"
    purpose: "Expose logout function from hook"
    key_changes:
      - "Added logout to hook return value"
      - "Import logout action from slice"

  - file: "src/components/UserMenu.tsx"
    scope_type: "modified"
    purpose: "Add logout button to menu"
    key_changes:
      - "Added LogoutButton component"
      - "Calls useAuth().logout() on click"

  - file: "src/components/UserMenu.test.tsx"
    scope_type: "created"
    purpose: "Test logout functionality"
    key_changes:
      - "Test button renders when logged in"
      - "Test logout action is called on click"

  - file: "src/types/auth.ts"
    scope_type: "modified"
    purpose: "Add LogoutAction type"
    key_changes:
      - "Added LogoutAction to union type"
```

Note:
- New dependencies introduced
- Patterns being used (or deviated from)
- Potential side effects

### 4. Verify

Run tests if possible:

```bash
npm test -- --coverage
# or
bun test
# or
pytest
```

```yaml
verification:
  tests_exist: true
  tests_pass: true
  test_output: "5 passed, 0 failed"
  coverage_change: "+2.3%"
```

### 5. Assess quality

Review against the shared review dimensions (see below). In standalone mode, skip spec compliance and design adherence.

### 6. Provide feedback

Compile findings into the feedback format (see below).

## Pipeline review process

1. **Load context**: Read implementation, spec, design, standards
2. **Run checks**: Go through each dimension systematically
3. **Document findings**: Record issues with specific locations
4. **Determine verdict**: Approve, request changes, or reject
5. **Provide feedback**: Explain issues with suggestions

## Review dimensions

### Shared dimensions

These apply in both pipeline and standalone modes.

#### Code quality

```yaml
code_quality:
  readability:
    status: "pass | fail"
    notes: "Clear function names, good structure"

  complexity:
    status: "pass | fail"
    notes: "No unnecessary abstractions"

  error_handling:
    status: "pass | fail"
    notes: "Errors caught and logged"

  maintainability:
    status: "pass | fail"
    notes: "Follows existing patterns"

  no_dead_code:
    status: "pass | fail"
    notes: "No dead code or commented code"

  naming_conventions:
    status: "pass | fail"
    notes: "Follows project conventions"
```

#### Security

```yaml
security:
  input_validation:
    status: "pass | fail | n/a"
    notes: ""

  no_injection_vulnerabilities:
    status: "pass | fail"
    notes: "Parameterised queries used"

  sensitive_data_handling:
    status: "pass | fail"
    notes: "No passwords logged, no PII in errors"

  auth_handling:
    status: "pass | fail | n/a"
    notes: ""

  no_hardcoded_secrets:
    status: "pass | fail"
    notes: ""
```

#### Standards compliance

```yaml
standards:
  naming_conventions:
    status: "pass | fail"
    notes: "Matches existing style"

  code_style:
    status: "pass | fail"
    notes: "Consistent with codebase"

  pattern_consistency:
    status: "pass | fail"
    notes: "Follows prescribed patterns"

  no_forbidden_patterns:
    status: "pass | fail"
    notes: ""
```

#### Test coverage

```yaml
test_coverage:
  tests_exist:
    status: "pass | fail"
    notes: ""

  key_paths_covered:
    status: "pass | fail"
    notes: "Happy path and error case tested"

  edge_cases:
    status: "pass | fail"
    notes: ""

  tests_maintainable:
    status: "pass | fail"
    notes: ""

  tests_pass:
    status: "pass | fail"
    notes: "All tests pass"
```

### Pipeline-only dimensions

These apply only when spec and design documents are available.

#### Spec compliance

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

#### Design adherence

Verify implementation follows the design:

```yaml
design_adherence:
  - item: "Uses layered architecture"
    status: "pass | fail"
    notes: "Controller -> Service -> Repository correctly implemented"

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

### Conditional dimensions

Include these when applicable, regardless of mode.

#### Runnability (CLI projects)

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

#### Migration safety (if applicable)

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

## Issue severity

- **Blocker**: Must fix (security flaw, data loss risk, broken functionality)
- **Major**: Should fix (significant quality issue, potential bugs, standards violation)
- **Minor**: Nice to fix (style preference, minor improvement)
- **Suggestion**: Optional enhancement

## Output

### Pipeline output

```yaml
code_review:
  story_id: "US-001"
  status: "approved | changes_requested | rejected"

  summary:
    spec_compliance: "3/3 passed"
    design_adherence: "4/4 passed"
    code_quality: "6/6 passed"
    security: "5/5 passed"
    standards: "4/4 passed"
    test_coverage: "5/5 passed"
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

### Standalone output

```yaml
review:
  scope:
    scope_type: "branch"
    reference: "feature/add-logout"
    files_changed: 5
    lines_added: 127
    lines_removed: 23

  intent:
    description: "Add logout functionality"
    source: "commit_messages"

  changes_summary:
    - file: "src/store/authSlice.ts"
      scope_type: "modified"
      purpose: "Add logout action"
      key_changes:
        - "Added logout reducer"
        - "Added clearTokens helper"
    # ...

  verification:
    tests_exist: true
    tests_pass: true
    manual_test_script:
      setup: "See README"
      scenarios:
        - name: "Happy path"
          steps:
            - action: "..."
              expect: "..."

  assessment:
    code_quality: "4/4 passed"
    security: "3/4 passed"
    standards: "3/3 passed"
    test_coverage: "5/5 passed"

  issues:
    - severity: "blocker"
      file: "src/store/authSlice.ts"
      line: 45
      description: "Token not cleared from localStorage"
      suggestion: "Add localStorage.removeItem('token')"
    # ...

  verdict:
    decision: "changes_requested"
    blocking_issues: 1
    total_issues: 4
    rationale: "Security issue needs fix"

  positive_notes:
    - "Clean implementation"
    - "Good test coverage"
```

## Feedback format

Present findings in readable format:

```markdown
## Code review: Changes requested

### Summary
Reviewed 5 files (+127/-23 lines) on branch `feature/add-logout`

**Intent:** Add logout functionality to user menu

### Issues to address

**[Blocker] Token not cleared from localStorage**
File: `src/store/authSlice.ts:45`

The logout action clears Redux state but doesn't remove the token from localStorage. Users remain authenticated on page refresh.

*Suggestion:* Add `localStorage.removeItem('token')` in the logout reducer.

---

**[Major] Missing loading state during logout**
File: `src/components/UserMenu.tsx:23`

Double-clicking the logout button could trigger multiple logout calls.

*Suggestion:* Add `isLoggingOut` state to disable the button during logout.

---

**[Minor] Unused import**
File: `src/hooks/useAuth.ts:12`

`useCallback` is imported but not used.

---

### What's working well
- Clean implementation following existing patterns
- Good test coverage for new functionality
- Clear commit messages

### Verdict
**Changes requested** - Please address the blocker before merge.
```

## Manual test script

When producing a manual test script, include it in both the structured output (`verification.manual_test_script`) and the feedback format.

```yaml
manual_test_script:
  setup: "Derived from project README — how to start the app and connect to data sources"
  scenarios:
    - name: "Short description of the scenario"
      steps:
        - action: "What the tester does"
          expect: "Observable outcome"
```

When building the manual test script:
- Derive setup instructions from the project README (already in context) rather than repeating them
- Create one scenario per behaviour introduced or changed by the diff
- Steps should be concrete and verifiable — describe what to do and what to observe, not "check it works"
- Include at least one happy-path scenario and one edge case or failure scenario

Present in feedback as:

```markdown
### Manual test script

**Setup:** See README — [relevant section or command]

| Scenario | Step | Action | Expected result |
|----------|------|--------|-----------------|
| Happy path | 1 | Perform the main user action | Expected observable outcome |
| Happy path | 2 | Verify side effects | Expected state change |
| Edge case | 1 | Trigger boundary condition | Expected handling |
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

## Tips

- Review objectively; focus on code, not coder
- Provide actionable feedback with examples
- Acknowledge good practices, not just problems
- If implementation is correct but design was flawed, note for future
- Security issues are always blockers
- Be thorough but proportional to change size
- When producing a manual test script, derive setup from the project README rather than repeating it. Focus scenarios on behaviours introduced by the diff.
- Review commit history structure: clear, atomic commits with meaningful messages make the change easier to understand and review
