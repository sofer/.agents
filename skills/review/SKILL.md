---
name: review
description: Review code that has already been written. Works without prior spec/design documents. Accepts PR URLs, branch names, commit ranges, or file lists. Use when you need to review existing changes.
---

# Review

Review code that has already been written, without requiring prior spec or design documents.

## Purpose

This skill provides standalone code review for:
- Pull requests
- Feature branches
- Commit ranges
- Specific file changes

Works independently of the orchestrated SDLC pipeline.

## Workflow

```
identify scope → understand intent → survey changes → assess quality → provide feedback
```

## Input

Accept any of:
- PR URL: `https://github.com/owner/repo/pull/123`
- Branch name: `feature/add-logout`
- Commit range: `main..feature/add-logout` or `abc123..def456`
- File list: `src/auth.ts src/login.tsx`

```yaml
review_request:
  type: "branch"  # pr | branch | commits | files
  reference: "feature/add-logout"
  focus: ""  # optional: specific areas to focus on
```

## Process

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
  type: "branch"
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
    type: "modified"
    purpose: "Add logout action to clear auth state"
    key_changes:
      - "Added logout reducer"
      - "Added clearTokens helper"

  - file: "src/hooks/useAuth.ts"
    type: "modified"
    purpose: "Expose logout function from hook"
    key_changes:
      - "Added logout to hook return value"
      - "Import logout action from slice"

  - file: "src/components/UserMenu.tsx"
    type: "modified"
    purpose: "Add logout button to menu"
    key_changes:
      - "Added LogoutButton component"
      - "Calls useAuth().logout() on click"

  - file: "src/components/UserMenu.test.tsx"
    type: "created"
    purpose: "Test logout functionality"
    key_changes:
      - "Test button renders when logged in"
      - "Test logout action is called on click"

  - file: "src/types/auth.ts"
    type: "modified"
    purpose: "Add LogoutAction type"
    key_changes:
      - "Added LogoutAction to union type"
```

Note:
- New dependencies introduced
- Patterns being used (or deviated from)
- Potential side effects

### 4. Assess quality

Review against key dimensions:

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
    notes: "Logout errors caught and logged"

  maintainability:
    status: "pass | fail"
    notes: "Follows existing patterns"
```

#### Security

```yaml
security:
  input_validation:
    status: "pass | fail | n/a"
    notes: ""

  no_secrets:
    status: "pass | fail"
    notes: "No hardcoded tokens or keys"

  injection_risks:
    status: "pass | fail | n/a"
    notes: ""

  auth_handling:
    status: "pass | fail | n/a"
    notes: "Tokens properly cleared on logout"
```

#### Standards

```yaml
standards:
  naming_conventions:
    status: "pass | fail"
    notes: "Matches existing camelCase style"

  code_style:
    status: "pass | fail"
    notes: "Consistent with codebase"

  pattern_consistency:
    status: "pass | fail"
    notes: "Follows Redux Toolkit patterns"
```

#### Test coverage

```yaml
test_coverage:
  tests_exist:
    status: "pass | fail"
    notes: "New test file added"

  key_paths_covered:
    status: "pass | fail"
    notes: "Happy path and error case tested"

  tests_pass:
    status: "pass | fail"
    notes: "All 5 tests pass"
```

### 5. Verification

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
  suggested_manual_tests:
    - "Log in, then click logout button"
    - "Verify redirect to login page"
    - "Verify session is cleared (check DevTools)"
```

### 6. Provide feedback

Compile findings into structured feedback:

#### Issues

```yaml
issues:
  - severity: "blocker"
    file: "src/store/authSlice.ts"
    line: 45
    description: "Token not cleared from localStorage"
    suggestion: "Add localStorage.removeItem('token') in logout action"

  - severity: "major"
    file: "src/components/UserMenu.tsx"
    line: 23
    description: "Missing loading state during logout"
    suggestion: "Add isLoggingOut state to prevent double-clicks"

  - severity: "minor"
    file: "src/hooks/useAuth.ts"
    line: 12
    description: "Unused import"
    suggestion: "Remove unused 'useCallback' import"

  - severity: "suggestion"
    file: "src/components/UserMenu.test.tsx"
    line: 30
    description: "Could add test for error handling"
    suggestion: "Add test case for logout failure scenario"
```

#### Verdict

```yaml
verdict:
  decision: "changes_requested"  # approved | changes_requested | rejected
  blocking_issues: 1
  total_issues: 4
  rationale: "One security issue must be addressed before merge"
```

#### Positive notes

```yaml
positive_notes:
  - "Clean implementation following existing patterns"
  - "Good test coverage for new functionality"
  - "Clear commit messages"
```

## Output

```yaml
review:
  scope:
    type: "branch"
    reference: "feature/add-logout"
    files_changed: 5
    lines_added: 127
    lines_removed: 23

  intent:
    description: "Add logout functionality"
    source: "commit_messages"

  changes_summary:
    - file: "src/store/authSlice.ts"
      type: "modified"
      purpose: "Add logout action"
    # ...

  verification:
    tests_exist: true
    tests_pass: true
    suggested_manual_tests:
      - "Click logout and verify redirect"

  assessment:
    code_quality: "4/4 passed"
    security: "3/4 passed"
    standards: "3/3 passed"
    test_coverage: "4/4 passed"

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
📍 `src/store/authSlice.ts:45`

The logout action clears Redux state but doesn't remove the token from localStorage. Users remain authenticated on page refresh.

*Suggestion:* Add `localStorage.removeItem('token')` in the logout reducer.

---

**[Major] Missing loading state during logout**
📍 `src/components/UserMenu.tsx:23`

Double-clicking the logout button could trigger multiple logout calls.

*Suggestion:* Add `isLoggingOut` state to disable the button during logout.

---

**[Minor] Unused import**
📍 `src/hooks/useAuth.ts:12`

`useCallback` is imported but not used.

---

### What's working well
- Clean implementation following existing patterns
- Good test coverage for new functionality
- Clear commit messages

### Verdict
**Changes requested** - Please address the blocker before merge.

### Suggested tests
After fixing, verify:
1. Log in, then click logout button
2. Refresh page - should remain logged out
3. Check DevTools - token should be gone from localStorage
```

## Issue severity

- **Blocker**: Must fix (security flaw, data loss risk, broken functionality)
- **Major**: Should fix (significant quality issue, potential bugs)
- **Minor**: Nice to fix (style, minor improvements)
- **Suggestion**: Optional enhancement

## Tips

- Focus on the code, not the author
- Provide actionable suggestions with examples
- Acknowledge what's done well
- If you can't determine intent, ask rather than assume
- Security issues are always blockers
- Be proportional - small changes need light reviews
