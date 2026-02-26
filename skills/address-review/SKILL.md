---
name: address-review
description: Read review comments on a GitHub PR, address them by fixing code, and reply to each comment. Use when a PR has received review feedback that needs to be acted on.
---

# Address review

Read review comments on a GitHub pull request, triage them, make code fixes, and respond to each comment. Closes the feedback loop between reviewer and author.

## Input

Accept any of:
- PR URL: `https://github.com/owner/repo/pull/123`
- PR number: `123` (infers repo from current directory)

```yaml
address_review:
  reference: "123"  # PR number or URL
  auto_push: false  # optional: push fixes without confirmation
```

## Workflow

```
fetch comments → categorise → fix → flag → commit → reply → re-request review
```

### 1. Fetch review comments

Gather all review feedback from the PR.

**Get PR metadata:**
```bash
gh pr view 123 --json number,title,headRefName,baseRefName,body,reviewDecision
```

**Get review summaries (top-level review verdicts):**
```bash
gh api repos/{owner}/{repo}/pulls/123/reviews
```

**Get inline comments (threaded discussion on specific lines):**
```bash
gh api repos/{owner}/{repo}/pulls/123/comments
```

**Get general PR comments (non-review discussion):**
```bash
gh api repos/{owner}/{repo}/issues/123/comments
```

### 2. Categorise comments

Sort each comment into one of three categories:

**Fix** — actionable feedback requiring a code change:
- Reviewer identifies a bug, security issue, or standards violation
- Reviewer requests a specific change ("rename this", "add validation here")
- Comment is tagged `[Blocker]` or `[Major]`

**Discuss** — requires human judgement before acting:
- Reviewer asks a question ("why did you choose X over Y?")
- Reviewer suggests an alternative approach
- Comment contradicts project conventions or other review feedback
- Disagreement with the reviewer's suggestion

**Acknowledge** — no code change needed:
- Reviewer leaves a positive note or minor suggestion
- Comment tagged `[Minor]` or `[Suggestion]` that doesn't warrant a change
- Informational comments

```yaml
categorised:
  fix:
    - id: 12345
      file: "src/store/authSlice.ts"
      line: 45
      body: "[Blocker] Token not cleared from localStorage"
      severity: "blocker"
      planned_action: "Add localStorage.removeItem('token') in logout reducer"

    - id: 12346
      file: "src/components/UserMenu.tsx"
      line: 23
      body: "[Major] Missing loading state during logout"
      severity: "major"
      planned_action: "Add isLoggingOut state to disable button"

  discuss:
    - id: 12347
      file: "src/hooks/useAuth.ts"
      line: 8
      body: "Have you considered using useReducer instead of useState here?"
      reason: "Design choice — needs user input"

  acknowledge:
    - id: 12348
      file: "src/hooks/useAuth.ts"
      line: 12
      body: "[Minor] Unused import: useCallback"
      planned_action: "Remove unused import"
```

Present the categorisation to the user before proceeding:

> **Review feedback on PR #123:**
>
> **Will fix (2):**
> - `src/store/authSlice.ts:45` — Token not cleared from localStorage [Blocker]
> - `src/components/UserMenu.tsx:23` — Missing loading state [Major]
>
> **Needs your input (1):**
> - `src/hooks/useAuth.ts:8` — Reviewer asks about useReducer vs useState
>
> **Will acknowledge (1):**
> - `src/hooks/useAuth.ts:12` — Remove unused import
>
> Proceed with fixes?

### 3. Fix code

For each comment categorised as **fix** or **acknowledge** (where a minor change is warranted):

1. Checkout the PR branch:
   ```bash
   gh pr checkout 123
   ```

2. Read the relevant file and understand the surrounding context

3. Make the code change. Address blockers first, then major, then minor.

4. After all fixes, run tests if a test command is available:
   ```bash
   npm test
   # or bun test, pytest, etc.
   ```

**Rules:**
- Fix only what the reviewer asked for — do not refactor adjacent code
- If a fix introduces a new issue or breaks tests, flag it to the user rather than improvising
- If two reviewer comments conflict, categorise both as **discuss**

### 4. Flag discussion items

For each comment categorised as **discuss**, present it to the user with context:

> **Reviewer comment on `src/hooks/useAuth.ts:8`:**
> "Have you considered using useReducer instead of useState here?"
>
> **Current code:** Uses useState for isLoggingOut flag
> **Reviewer's suggestion:** Switch to useReducer
>
> How would you like to respond?

Wait for user direction before acting on discussion items. The user may:
- Agree with the reviewer → recategorise as **fix** and implement
- Disagree → provide a response to post as a reply
- Defer → skip for now

### 5. Commit fixes

Use the commit skill conventions:

```
fix(auth): clear token from localStorage on logout

Addresses review feedback on PR #123.
```

**Guidelines:**
- Group related fixes into a single commit when they address the same concern
- Use separate commits for unrelated fixes
- Reference the PR in the commit message
- Follow Conventional Commits format

Push the fixes:
```bash
git push
```

### 6. Reply to comments

After fixes are committed and pushed, reply to each comment on GitHub.

**For fixed items:**
```bash
gh api repos/{owner}/{repo}/pulls/123/comments/{comment_id}/replies \
  --method POST \
  --field body="Fixed — added localStorage.removeItem('token') in the logout reducer. See $(git rev-parse --short HEAD)."
```

**For acknowledged items (minor fixes):**
```bash
gh api repos/{owner}/{repo}/pulls/123/comments/{comment_id}/replies \
  --method POST \
  --field body="Fixed — removed unused import."
```

**For discussion items (after user provides direction):**
```bash
gh api repos/{owner}/{repo}/pulls/123/comments/{comment_id}/replies \
  --method POST \
  --field body="User's response here."
```

**For acknowledged items (no change needed):**
```bash
gh api repos/{owner}/{repo}/pulls/123/comments/{comment_id}/replies \
  --method POST \
  --field body="Acknowledged — keeping as-is because [reason]."
```

**Reply to top-level review comments** (non-inline) using the issues API:
```bash
gh api repos/{owner}/{repo}/issues/123/comments \
  --method POST \
  --field body="Response here."
```

**Rules:**
- Always reference the commit SHA when replying to a fixed item
- Keep replies concise — one or two sentences
- Never post replies without user confirmation
- Batch-show all planned replies before posting

### 7. Re-request review

After all comments are addressed and replies posted:

```bash
gh api repos/{owner}/{repo}/pulls/123/requested_reviewers \
  --method POST \
  --field 'reviewers=["reviewer-username"]'
```

Get the reviewer username from the reviews fetched in step 1.

## Output

```yaml
address_review:
  pr: 123
  comments_total: 4
  fixed: 3
  discussed: 1
  acknowledged: 0
  commits:
    - sha: "abc1234"
      message: "fix(auth): clear token from localStorage on logout"
    - sha: "def5678"
      message: "fix(ui): add loading state to logout button"
  replies_posted: 4
  review_re_requested: true
  reviewer: "reviewer-username"
```

## Tips

- Read the full review before starting fixes — comments may be related or contradictory
- Address blockers first; a blocker left unfixed makes other fixes pointless
- When a reviewer is wrong, respond respectfully with evidence rather than silently ignoring
- If the PR has multiple reviewers, address each reviewer's feedback and re-request review from all of them
- Check for dismissed reviews — they may contain feedback that was superseded by newer comments
