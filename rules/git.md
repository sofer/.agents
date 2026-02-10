# Git workflow

## Commit messages

Use conventional commits format with a thorough body:

```
<type>(<scope>): <short summary>

<body - explain WHY, not just WHAT>

<footer - references, breaking changes>
```

**Subject line:**
- Imperative mood ("add" not "added")
- Under 50 characters
- No period at end
- Type: feat, fix, docs, refactor, test, chore

**Body:**
- Blank line after subject
- Explain the motivation and context
- What problem does this solve?
- Why this approach vs alternatives?
- What should future readers know?

**Footer (optional):**
- `Refs: #123` or `Closes: #456`
- `BREAKING CHANGE: description`

### Example

```
feat(auth): add session timeout handling

Users were staying logged in indefinitely, creating security risk
for shared computers. Sessions now expire after 24 hours of
inactivity.

Considered shorter timeout but UX research showed users found
< 24h frustrating for daily-use apps.

Closes: #142
```

## Branches

- Use kebab-case: `feature/add-auth`, `fix/login-bug`
- Prefix with type: `feature/`, `fix/`, `chore/`, `docs/`

## Workflow

- Check `git status` before committing
- Stage specific files, not `git add .`
- For complex changes, create atomic commits per logical unit
- Never use `--no-verify`
