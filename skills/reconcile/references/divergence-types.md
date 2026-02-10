# Divergence types

Detailed documentation of all divergence types detected by the reconcile skill, including detection methods, edge cases, and resolution strategies.

## Phase drift

**Description:** The manifest phase for a story is behind the actual progress indicated by existing files and commits.

**Detection method:**

1. Read story phase from manifest
2. Check for artifacts that indicate later phases:
   - `design.md` exists → at least "design" phase
   - Implementation files matching story scope → at least "implement" phase
   - Tests passing → at least "implement" complete
   - PR exists → at least "commit:pr" phase
   - PR merged → "complete" status

3. Compare manifest phase to detected phase
4. If detected > manifest → phase drift

**Examples:**

| Manifest phase | Actual state | Drift? |
|----------------|--------------|--------|
| spec | design.md exists | Yes |
| design | scoring.py, triage.py exist | Yes |
| implement | tests pass, code committed | Yes |
| commit:pr | PR merged | Yes |
| complete | all artifacts present | No |

**Edge cases:**

- Partial implementation: Some files exist but feature incomplete
  - Resolution: Check test pass rate, if tests fail, implementation incomplete
- Prototype code: Code exists but isn't production-ready
  - Resolution: Ask user if this is throwaway or should be formalised

**Resolution strategies:**

1. **Auto-advance phase** (safe)
   - Update manifest phase to match actual state
   - Add artifact references for existing files

2. **Backfill artifacts** (unsafe)
   - Create retrospective spec/design documents
   - Requires user confirmation on content

## Uncommitted implementation

**Description:** Implementation files exist in the working tree but have not been committed.

**Detection method:**

1. Run `git status` to get untracked and modified files
2. Match files against story scope patterns:
   - Files mentioned in design.md
   - Files matching story feature area
   - Files with story ID in comments
3. If matches found and story phase is "implement" or later → uncommitted implementation

**Examples:**

```
# Uncommitted files
scoring.py (new)
triage.py (new)
writeback.py (new)

# Story US-004 scope: lead scoring and triage
# Match: all three files relate to scoring/triage
```

**Edge cases:**

- Files belong to multiple stories
  - Resolution: Ask user to assign, or split into multiple commits
- Files are work-in-progress
  - Resolution: Ask if ready to commit or should remain uncommitted
- Files are experimental/throwaway
  - Resolution: Ask if should be deleted or formalised

**Resolution strategies:**

1. **Commit with story message** (unsafe)
   - Stage matched files
   - Commit with conventional message referencing story
   - Requires user confirmation

2. **Stage only** (safe)
   - Add files to staging area
   - Let user decide when to commit

3. **Create checkpoint** (safe)
   - Record files in manifest as "work in progress"
   - No git operations

## Missing artifacts

**Description:** Manifest references artifact files that do not exist on disk.

**Detection method:**

1. For each artifact path in manifest story:
   ```yaml
   artifacts:
     spec: ".sdlc/stories/US-004/spec.md"
     design: ".sdlc/stories/US-004/design.md"
   ```
2. Check if file exists at path
3. If file missing → missing artifact

**Edge cases:**

- File was deleted intentionally
  - Resolution: Remove reference from manifest
- File was moved/renamed
  - Resolution: Search for file by name, update path
- File never existed (copy-paste error)
  - Resolution: Remove reference or create file

**Resolution strategies:**

1. **Remove reference** (safe)
   - Delete artifact entry from manifest
   - Log removal

2. **Create placeholder** (unsafe)
   - Create empty file with template
   - Requires user to fill in content

3. **Search and link** (safe)
   - Find file elsewhere in project
   - Update manifest path

## Orphan artifacts

**Description:** Files exist in `.sdlc/stories/` directories but are not referenced in the manifest.

**Detection method:**

1. List all files in `.sdlc/stories/*/`
2. Collect all artifact paths from manifest
3. Files in (1) not in (2) → orphan artifacts

**Examples:**

```
# Files in .sdlc/stories/US-004/
spec.md          # in manifest
design.md        # in manifest
notes.md         # NOT in manifest (orphan)
scratch.py       # NOT in manifest (orphan)
```

**Edge cases:**

- Temporary/scratch files
  - Resolution: Delete or move to scratchpad
- Legitimate artifacts not yet added
  - Resolution: Add to manifest
- Old versions/backups
  - Resolution: Delete or archive

**Resolution strategies:**

1. **Add to manifest** (safe)
   - Create artifact entry for orphan file
   - Infer type from filename/extension

2. **Delete file** (unsafe)
   - Remove orphan file
   - Requires user confirmation

3. **Ignore** (safe)
   - Leave as-is
   - Some orphans are acceptable

## Stale branch

**Description:** A feature branch exists locally but has already been merged to main.

**Detection method:**

1. List all local branches: `git branch`
2. For branches matching story pattern (e.g., `story/US-XXX-*`):
   - Check if branch is merged: `git branch --merged main`
   - Or check if branch tip is ancestor of main
3. If merged → stale branch

**Examples:**

```bash
# Local branches
main
story/US-003-match-gmail-correspondence  # merged to main
story/US-004-lead-scoring                # not merged

# Stale: story/US-003-match-gmail-correspondence
```

**Edge cases:**

- Branch has commits not in main (diverged after merge)
  - Resolution: Warn user, do not auto-delete
- Branch is tracking remote that still exists
  - Resolution: Delete local only, warn about remote
- Branch is the current branch
  - Resolution: Cannot delete, suggest checkout main first

**Resolution strategies:**

1. **Delete local branch** (safe, if truly merged)
   - `git branch -d {branch}`
   - Only for fully merged branches

2. **Delete local and remote** (unsafe)
   - `git branch -d {branch}`
   - `git push origin --delete {branch}`
   - Requires confirmation

## Status mismatch

**Description:** A story is marked as complete in the manifest but evidence suggests it's not actually complete.

**Detection method:**

1. For stories with `status: complete`:
   - Check all expected artifacts exist
   - Check implementation files exist
   - Check tests pass
   - Check branch merged or PR closed
2. If any check fails → status mismatch

**Examples:**

| Story | Status | Issue |
|-------|--------|-------|
| US-002 | complete | Tests failing |
| US-003 | complete | PR still open |
| US-001 | complete | No issues (valid) |

**Edge cases:**

- Tests were passing, now fail due to other changes
  - Resolution: Create regression bug, keep status complete
- PR was reopened after merge
  - Resolution: Update status to in-progress
- Manual override (user marked complete despite issues)
  - Resolution: Respect user intent, just warn

**Resolution strategies:**

1. **Revert to in-progress** (unsafe)
   - Change status back to in-progress
   - Set appropriate phase
   - Requires confirmation

2. **Create follow-up story** (unsafe)
   - Keep status complete
   - Create new story for remaining work

3. **Warn only** (safe)
   - Report mismatch
   - Take no action

## Untracked functionality

**Description:** Implementation exists that doesn't correspond to any story in the manifest.

**Detection method:**

1. Identify all implementation files not associated with stories:
   - Files not in any story's artifact list
   - Files not mentioned in any design.md
   - Files with no story ID in commit messages
2. Exclude infrastructure files (config, CI, etc.)
3. Remaining files → untracked functionality

**Examples:**

```
# Untracked files (not in any story)
collect.py        # data collection script
match.py          # matching utility
next.py           # CLI helper
status.py         # status display

# These appear to be utilities built ad-hoc
```

**Edge cases:**

- Infrastructure/tooling (intentionally no story)
  - Resolution: Mark as infrastructure in manifest
- Spike/prototype (temporary)
  - Resolution: Delete or formalise into story
- Belongs to story but wasn't tracked
  - Resolution: Associate with existing story

**Resolution strategies:**

1. **Create new story** (unsafe)
   - Add story to manifest
   - Associate files as artifacts
   - Requires user input for story details

2. **Associate with existing story** (unsafe)
   - Add files to existing story's artifacts
   - Update story scope if needed

3. **Mark as infrastructure** (safe)
   - Add to manifest infrastructure section
   - No story association needed

## Branch mismatch

**Description:** The currently checked out branch doesn't match the expected branch for the current story.

**Detection method:**

1. Get current branch: `git branch --show-current`
2. Get expected branch from manifest for current_story
3. If current != expected → branch mismatch

**Examples:**

| Current branch | Expected branch | Mismatch? |
|----------------|-----------------|-----------|
| main | story/US-004-scoring | Yes |
| story/US-003-gmail | story/US-004-scoring | Yes |
| story/US-004-scoring | story/US-004-scoring | No |

**Edge cases:**

- No current_story set
  - Resolution: Being on main is expected
- Story doesn't have branch yet (pre-branch phase)
  - Resolution: No mismatch
- Detached HEAD state
  - Resolution: Warn, suggest checkout

**Resolution strategies:**

1. **Checkout correct branch** (safe, if no uncommitted changes)
   - `git checkout {expected_branch}`
   - Only if working tree is clean

2. **Stash and checkout** (unsafe)
   - `git stash`
   - `git checkout {expected_branch}`
   - Requires confirmation

3. **Update manifest** (unsafe)
   - Change current_story to match current branch
   - Requires confirmation
