---
name: commit
description: Git workflow operations with Conventional Commits. Supports subcommands - branch (create feature branch), commit (stage and commit changes), pr (create pull request), merge (merge PR). Automatically available when the current directory is a git repository. Use when user needs git operations during development workflow.
---

# Git workflow

Git operations following Conventional Commits and configurable branching strategies.

## Subcommands

Invoke with subcommand argument:
- `commit branch` - Create feature branch
- `commit commit` or just `commit` - Stage and commit changes
- `commit pr` - Create pull request
- `commit merge` - Merge pull request

When invoked without subcommand, default to commit behaviour.

---

## branch

Create a feature branch for a story or task.

### Input
- Story ID and title/slug (from orchestrator or user)
- Git strategy: `feature-branch` or `trunk-based`
- Branch pattern (default: `story/{id}-{slug}`)

### Process

1. Ensure working directory is clean:
   ```bash
   git status --porcelain
   ```
   If not clean, ask user to stash or commit changes first.

2. Fetch latest from remote:
   ```bash
   git fetch origin
   ```

3. Determine base branch:
   - Default: `main` or `master` (whichever exists)
   - For trunk-based: always use main branch
   - For feature-branch: use main or specified base

4. Create and checkout branch:
   ```bash
   git checkout -b story/US-001-user-login origin/main
   ```

### Branch naming

Generate slug from story title:
- Lowercase
- Replace spaces with hyphens
- Remove special characters
- Truncate to 50 characters

Examples:
- `story/US-001-user-registration`
- `story/US-042-fix-login-timeout`
- `feature/US-103-dashboard-charts`

### Output
- Branch created and checked out
- Report branch name to user/orchestrator

---

## commit

Stage changes and create commit with Conventional Commits format.

### Process

1. Review changes:
   ```bash
   git status
   git diff
   git diff --cached  # staged changes
   ```

2. Stage changes (if not already staged):
   - Ask user which files to stage, or
   - Stage all with `git add -A` if user confirms
   - **Never stage user-test artifacts** (formatted test scripts, `.sdlc/stories/*/user-test-results.yaml`). These are pipeline-internal files and must not be committed. If staged accidentally, unstage them before committing.

3. Determine commit type from changes:
   - **feat**: New features
   - **fix**: Bug fixes
   - **docs**: Documentation changes
   - **style**: Code style (formatting, semicolons)
   - **refactor**: Code restructuring without feature changes
   - **test**: Adding or updating tests
   - **chore**: Maintenance (build, dependencies)

4. Format commit message:
   ```
   <type>(<scope>): <description>
   ```

### Guidelines

- Use lowercase for type and description
- Keep description under 50 characters
- Use imperative mood: "add feature" not "added feature"
- Scope is optional but recommended (component/module name)
- Reference story ID when available: `feat(auth): add login (US-001)`
- **No attribution footers** (no "Generated with...", no "Co-Authored-By")

### Examples

```
feat(user): add registration endpoint (US-001)
fix(auth): resolve token expiry issue (US-023)
test(user): add unit tests for validation
refactor(api): extract common middleware
docs: update API documentation
chore(deps): upgrade typescript to 5.0
```

### Execution

1. Propose message to user
2. On approval: `git commit -m "message"`
3. Confirm success

---

## pr

Create a pull request for the current branch.

### Process

1. Ensure commits are pushed:
   ```bash
   git push -u origin HEAD
   ```

2. Verify no user-test artifacts are committed:
   - Check that no `.sdlc/stories/*/user-test-results.yaml` or formatted test script files are in the commit history
   - If found, remove them from tracking before pushing

3. Gather PR context:
   - Story ID and title (from manifest or branch name)
   - Summary of changes (from commits)
   - Acceptance criteria (from story)

4. Generate PR description:
   ```markdown
   ## Summary
   Brief description of what this PR does.

   ## Story
   US-001: User Registration

   ## Changes
   - Added user registration endpoint
   - Implemented email validation
   - Added unit tests

   ## Acceptance criteria
   - [x] User can register with email and password
   - [x] Invalid emails are rejected
   - [x] Duplicate emails return appropriate error

   ## Testing
   - Unit tests added and passing
   - User testing passed
   ```

   **Do not include** manual test scripts, formatted test scenarios, or user-test result details in the PR description. The Testing section should only confirm that tests passed, not reproduce test content.

5. Create PR:
   ```bash
   gh pr create --title "feat(user): add registration (US-001)" --body "..."
   ```

   Or if `gh` not available, provide URL:
   ```
   https://github.com/{owner}/{repo}/compare/{branch}?expand=1
   ```

### PR title format

Follow Conventional Commits:
```
<type>(<scope>): <description> (<story-id>)
```

### Output
- PR URL
- Update manifest with PR reference

---

## merge

Merge an approved pull request.

### Process

1. Check PR status:
   ```bash
   gh pr status
   gh pr checks
   ```

2. Verify approval:
   - PR must be approved
   - All checks must pass
   - No merge conflicts

3. Merge with appropriate strategy:
   ```bash
   # Squash merge (default for feature branches)
   gh pr merge --squash --delete-branch

   # Merge commit (preserves history)
   gh pr merge --merge --delete-branch

   # Rebase (linear history)
   gh pr merge --rebase --delete-branch
   ```

4. Update local:
   ```bash
   git checkout main
   git pull origin main
   ```

### Merge strategy selection

- **Squash**: Default for feature branches, clean history
- **Merge**: When preserving individual commits matters
- **Rebase**: For linear history preference

Ask user or check project config for preference.

### Output
- Confirm merge complete
- Report merged commit SHA
- Update manifest: mark story as merged

---

## Configuration

When used with orchestrator, read from manifest:

```yaml
project:
  git:
    strategy: "feature-branch"
    pattern: "story/{id}-{slug}"
    auto_pr: true
    merge_strategy: "squash"
```

## Notes

- Follows Conventional Commits (conventionalcommits.org)
- Platform-agnostic (works with GitHub, GitLab, Bitbucket)
- Uses `gh` CLI when available for GitHub operations
- Falls back to manual instructions when CLI not available
