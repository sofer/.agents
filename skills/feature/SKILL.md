---
name: feature
description: Implement a feature in an existing codebase. Streamlined entry point that bypasses intent/requirements phases and focuses on rapid delivery. Use when you have a specific feature to build.
---

# Feature

Implement a feature in an existing codebase with a streamlined workflow.

## Purpose

This skill provides a fast path for implementing features in existing codebases:
- Bypasses intent/requirements phases
- Surveys codebase to understand conventions
- Scales complexity handling based on feature size
- Delivers working, tested code ready to commit

## Workflow

```
capture request → understand codebase → lightweight design → implement + test → review → commit
```

## Process

### 0. Git setup

Before making any code changes, ensure you're on a feature branch:

1. **Check current branch:**
   - If on `main` or `master`, create a feature branch first
   - If already on a feature branch, proceed

2. **Create feature branch (if needed):**
   - Use `commit branch` subcommand to create and switch to a new branch
   - Branch name should reflect the feature (e.g., `feat/add-logout-button`)

This assumes a feature-branch workflow where:
- Changes are developed on feature branches
- PRs are opened for review before merging
- Main branch stays stable

For solo projects where you commit directly to main, skip this step.

### 1. Capture request

Gather minimal information about the feature:

**Required:**
- What to build (1-3 sentences describing the feature)

**Optional (can be inferred):**
- Where it should integrate (module, file, component)
- Constraints (performance, compatibility, dependencies)
- Acceptance criteria (how to verify it works)

```yaml
feature_request:
  description: "Add a logout button to the user menu that clears the session"
  integration_point: "src/components/UserMenu.tsx"  # optional
  constraints: []  # optional
  acceptance_criteria:  # optional
    - "Button visible when user is logged in"
    - "Clicking clears session and redirects to login"
```

If the user hasn't provided enough detail, ask brief clarifying questions. Avoid lengthy requirements gathering.

### 2. Understand codebase

Survey the project to understand conventions:

1. **Read project docs:**
   - AGENTS.md or README for project overview
   - Check for documented patterns and conventions
   - Note testing approach and tools

2. **Scan structure:**
   - Identify relevant directories
   - Find related modules and components
   - Understand the architecture pattern in use

3. **Study existing patterns:**
   - How similar features are implemented
   - Naming conventions in practice
   - Error handling approach
   - Test patterns used

```yaml
codebase_context:
  architecture: "React + Redux, component-based"
  related_modules:
    - "src/components/UserMenu.tsx"
    - "src/store/authSlice.ts"
    - "src/hooks/useAuth.ts"
  patterns:
    - "Functional components with hooks"
    - "Redux Toolkit for state"
    - "Jest + RTL for testing"
  conventions:
    naming: "camelCase functions, PascalCase components"
    testing: "Co-located test files (*.test.tsx)"
```

### 3. Assess complexity

Determine feature size to choose appropriate workflow:

| Size | Criteria | Workflow |
|------|----------|----------|
| **S** (Small) | Single file change, <50 lines, isolated | Direct implementation |
| **M** (Medium) | 2-5 files, clear scope, follows patterns | Lightweight design first |
| **L** (Large) | 5+ files, new patterns, architectural impact | Full pipeline |

```yaml
complexity:
  size: "M"
  rationale: "Touches 3 files (component, store, hook), follows existing patterns"
  files_affected:
    - "src/components/UserMenu.tsx"
    - "src/store/authSlice.ts"
    - "src/hooks/useAuth.ts"
```

### 4. Design (M and L only)

For medium and large features, create a brief design plan:

```yaml
design:
  approach: "Add logout action to auth slice, expose via useAuth hook, add button to UserMenu"
  components:
    - name: "logout action"
      location: "src/store/authSlice.ts"
      changes: "Add logout reducer that clears user state"
    - name: "useAuth hook"
      location: "src/hooks/useAuth.ts"
      changes: "Expose logout function"
    - name: "UserMenu"
      location: "src/components/UserMenu.tsx"
      changes: "Add logout button that calls useAuth().logout()"
  integration:
    - "Button triggers logout action"
    - "Logout clears Redux state"
    - "Router redirects to /login"
  risks: []
```

For large features, delegate to full pipeline:
```
invoke: design → stubs → test → implement → refactor → code-review
```

### 5. Implement

Write the code following existing patterns:

**For small features:**
- Write implementation and tests together
- Keep changes minimal and focused

**For medium features:**
- Implement component by component
- Write tests as you go
- Run tests frequently

**For large features:**
- Follow TDD: stubs → tests (red) → implement (green) → refactor
- Use the dedicated phase skills

```yaml
implementation:
  files_modified:
    - path: "src/store/authSlice.ts"
      changes: "Added logout action"
    - path: "src/hooks/useAuth.ts"
      changes: "Exposed logout from hook"
    - path: "src/components/UserMenu.tsx"
      changes: "Added logout button"
  files_created: []
  tests_added:
    - "src/components/UserMenu.test.tsx"
  test_result:
    passed: 5
    failed: 0
```

### 6. Review

Perform abbreviated quality check:

```yaml
review:
  code_quality:
    - "Follows existing patterns": "pass"
    - "No unnecessary complexity": "pass"
    - "Error handling appropriate": "pass"
  security:
    - "No secrets exposed": "pass"
    - "Input validated": "pass"
  standards:
    - "Naming conventions": "pass"
    - "Code style consistent": "pass"
  tests:
    - "Key paths covered": "pass"
    - "Tests pass": "pass"
  issues: []
  verdict: "approved"
```

If issues found, fix before proceeding.

### 7. Commit

Create a conventional commit:

```bash
git add <files>
git commit -m "feat(auth): add logout button to user menu

- Add logout action to auth slice
- Expose logout via useAuth hook
- Add logout button to UserMenu component
- Add tests for logout functionality"
```

## Output

```yaml
feature:
  request: "Add logout button to user menu"
  complexity: "M"

  codebase_survey:
    architecture: "React + Redux"
    related_modules: [...]
    patterns: [...]

  design:
    approach: "..."
    components: [...]

  implementation:
    files_modified: [...]
    files_created: [...]
    tests_added: [...]
    test_result: { passed: 5, failed: 0 }

  review:
    verdict: "approved"
    issues: []

  commit:
    hash: "abc123"
    message: "feat(auth): add logout button to user menu"
```

## Complexity handling

### Small (S) - Direct implementation

```
request → understand → implement + test → quick review → commit
```

- Skip formal design
- Write code and tests together
- Brief review focused on obvious issues

### Medium (M) - Lightweight design

```
request → understand → design brief → implement + test → review → commit
```

- Quick design document (not saved to .sdlc/)
- Implement following the plan
- Standard review

### Large (L) - Full pipeline

```
request → understand → invoke full pipeline
```

Delegate to orchestrated flow:
1. Create story in backlog
2. Run: design → design-review → stubs → test → implement → refactor → code-review → commit

## Tips

- Start with understanding the codebase; don't assume patterns
- Match existing code style exactly
- Write tests for new functionality
- Keep changes focused on the requested feature
- If scope grows beyond initial estimate, reassess complexity
- When in doubt, ask a clarifying question rather than assume
