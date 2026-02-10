---
name: reconcile
description: Analyse and resolve divergences between SDLC manifest and actual development state (git commits, branches, uncommitted files). Use when manifest and reality have drifted apart, or before picking next story to ensure clean state.
---

# SDLC Reconciliation

Analyse divergences between the SDLC manifest and actual development state, then propose and execute corrections to bring them into agreement.

## Process overview

```
[1. Collect state]
Git: log, branch, status, diff
Manifest: .sdlc/manifest.yaml
Files: .sdlc/stories/*/

[2. Detect divergences]
Compare expected vs actual state
Categorise by type and severity

[3. Generate report]
Summary of manifest state
Summary of git state
List of divergences

[4. Propose corrections]
Safe corrections (auto-apply candidates)
Unsafe corrections (require confirmation)

[5. Execute corrections]
Apply approved changes
Update manifest
```

## Commands

| Command | Behaviour |
|---------|-----------|
| `/reconcile` | Full analysis and interactive correction |
| `/reconcile --report` | Report only, no corrections |
| `/reconcile --auto` | Apply safe corrections automatically |
| `/reconcile --story US-XXX` | Focus on specific story |

## Divergence types

| Type | Description | Severity |
|------|-------------|----------|
| Phase drift | Manifest phase behind actual progress | Medium |
| Uncommitted implementation | Code exists but not committed | High |
| Missing artifacts | Manifest references non-existent files | Medium |
| Orphan artifacts | Files exist but not in manifest | Low |
| Stale branch | Merged branch still exists locally | Low |
| Status mismatch | Story marked complete but has issues | High |
| Untracked functionality | Implementation exists with no story | High |
| Branch mismatch | Wrong branch checked out for story | Medium |

See [references/divergence-types.md](references/divergence-types.md) for detailed detection methods and resolution strategies.

## Workflow

### 1. Collect state

Gather information from three sources:

**Git state:**
```bash
git log --oneline -20           # Recent commits
git branch -a                    # All branches
git status                       # Working tree state
git diff --name-only             # Changed files
git diff --cached --name-only    # Staged files
```

**Manifest state:**
- Read `.sdlc/manifest.yaml`
- Extract current_story, story phases, artifact references
- Note backlog and completed stories

**File state:**
- List `.sdlc/stories/*/` directories
- Check for spec.md, design.md, and other artifacts
- Compare against manifest references

### 2. Detect divergences

For each story in manifest:

1. **Check phase accuracy:**
   - If phase is "spec" but design.md exists → phase drift
   - If phase is "design" but implementation files exist → phase drift
   - If phase is "implement" but tests pass and code committed → phase drift

2. **Check artifacts:**
   - For each artifact in manifest, verify file exists
   - For each file in story directory, verify manifest reference

3. **Check git state:**
   - If story branch exists and is merged → stale branch
   - If uncommitted files match story scope → uncommitted implementation
   - If current branch doesn't match current_story → branch mismatch

4. **Check for untracked work:**
   - New files not matching any story
   - Commits not associated with any story

### 3. Generate report

Format:

```markdown
# Reconciliation report

## Manifest state

- Project: {name}
- Current story: {id} - {title}
- Current phase: {phase}
- Stories in progress: {count}
- Stories complete: {count}

## Git state

- Current branch: {branch}
- Uncommitted files: {count}
- Staged files: {count}
- Recent commits: {list}

## Divergences found

### High severity

- [ ] **Uncommitted implementation** (US-004)
  - Files: scoring.py, triage.py, writeback.py
  - Expected: committed during implement phase
  - Actual: exist but uncommitted

### Medium severity

- [ ] **Phase drift** (US-004)
  - Manifest phase: design
  - Actual progress: implementation exists
  - Evidence: scoring.py, triage.py present

### Low severity

- [ ] **Stale branch**
  - Branch: story/US-003-match-gmail-correspondence
  - Status: merged to main
  - Action: can be deleted

## Stale branches

| Branch | Status | Last commit |
|--------|--------|-------------|
| story/US-003-match-gmail-correspondence | merged | cc3128f |
```

### 4. Propose corrections

Present corrections in two categories:

**Safe corrections (can auto-apply):**

```markdown
## Safe corrections

These can be applied automatically with `--auto`:

1. **Update US-004 phase** design → implement
   - Reason: implementation files exist

2. **Add artifact references to US-004**
   - Add: scoring.py, triage.py, writeback.py

3. **Delete stale branch**
   - Branch: story/US-003-match-gmail-correspondence
```

**Unsafe corrections (require confirmation):**

```markdown
## Unsafe corrections

These require explicit approval:

1. **Commit uncommitted changes for US-004**
   - Files: scoring.py, triage.py, writeback.py
   - Message: "feat(scoring): implement lead scoring (US-004)"
   - Risk: may include unintended changes

2. **Create story for untracked functionality**
   - Files: collect.py, match.py, next.py
   - Suggested: US-005 "Additional utility scripts"
   - Risk: may miscategorise functionality

3. **Mark US-004 as current_story**
   - Current: null
   - Proposed: US-004
   - Risk: overwrites any existing current_story intent
```

### 5. Execute corrections

For safe corrections with `--auto`:
1. Apply each correction in sequence
2. Update manifest after each change
3. Report results

For unsafe corrections:
1. Present each correction individually
2. Wait for explicit yes/no
3. Apply only approved corrections
4. Update manifest

## Safe vs unsafe corrections

### Safe (auto-apply candidates)

These corrections have low risk and clear intent:

- Update phase forward (spec → design → implement → etc.)
- Add artifact references to manifest for existing files
- Delete merged feature branches
- Add missing story directories for manifest entries

### Unsafe (require confirmation)

These corrections could lose work or make incorrect assumptions:

- Create new stories
- Delete or modify existing stories
- Commit changes
- Change current_story
- Mark stories as complete
- Delete uncommitted files
- Revert changes
- Update phase backward

## Edge cases

### No manifest exists

If `.sdlc/manifest.yaml` does not exist:

1. Report: "No SDLC manifest found"
2. Check for `.sdlc/` directory
3. If story artifacts exist without manifest, offer to reconstruct
4. Otherwise, suggest running project initialisation

### Multiple stories in uncommitted changes

When uncommitted files could belong to multiple stories:

1. Group files by likely story based on:
   - File paths matching story scope
   - Recent commit messages
   - Manifest artifact patterns
2. Present groupings for user confirmation
3. Allow manual reassignment

### Partial artifacts

When some artifacts exist but story phase suggests they shouldn't:

1. If earlier artifacts missing (e.g., design exists but no spec):
   - Offer to create retrospective spec
   - Or mark as "spec skipped" in manifest
2. If later artifacts missing (e.g., spec exists but no design):
   - Normal state, no correction needed

### Orphan implementation files

Files that look like implementation but match no story:

1. Check commit history for associated story references
2. Check file contents for story ID comments
3. If no association found:
   - Offer to create new story
   - Or associate with existing story
   - Or mark as infrastructure/utility

## Integration with orchestrate

When orchestrate skill detects potential drift:

1. Pause pipeline
2. Invoke `/reconcile --report`
3. Present findings to user
4. Offer to apply corrections or continue anyway

Triggers for drift check:
- Before picking next story
- At phase transitions
- When resuming after pause
