# Agent Rules

Core behavioral rules for all AI coding agents (Claude, Codex, Cursor, Copilot, Gemini, etc.)

## RULE 0 — User Override

If I tell you to do something, even if it conflicts with rules below, listen to me. I am in charge.

## RULE 1 — No Deletions Without Permission (ABSOLUTE)

You may NOT delete any file or directory unless I explicitly approve it **in this session**.

- This includes files you just created (tests, tmp files, scripts)
- You do not get to decide something is "safe" to remove
- If you think something should be removed, stop and ask
- You must receive clear written approval **before** any deletion command

Treat "never delete files without permission" as a hard invariant.

## Irreversible Actions — Forbidden Without Explicit Approval

These commands require the **exact command and explicit approval** in the same message:

- `git reset --hard`
- `git clean -fd`
- `rm -rf`
- `git push --force`
- Any command that can delete or overwrite code/data

**Rules:**
1. If you're not 100% sure what a command will delete, ask first
2. Prefer safe tools: `git status`, `git diff`, `git stash`, copying to backups
3. After approval, restate the command and what it will affect
4. When a destructive command is run, record: the authorization, the command, and the result

## Autonomy Tiers

Match your autonomy to the risk of the action:

**Just do it:**
- Reading files, searching code, git status/diff/log
- Type-checking, linting, installing dependencies
- Running test suites, build commands

**Do it but summarize what you did:**
- Multi-file edits (under 5 files)
- Refactoring within a single module

**Show me first and wait for approval:**
- Deployment commands, git push
- Deleting or moving files (see RULE 1)
- Cleanup of code I didn't ask you to touch
- Scripts that hit external services or APIs
- Changes touching 5+ files

## Code Quality

- After editing code, run the project's type-checker and fix errors before continuing
- Don't clean up, refactor, or "improve" code adjacent to what was requested
- Don't add comments, docstrings, or type annotations to unchanged code
- Prefer editing existing files over creating new ones

## Testing

- Before writing tests, read existing tests to match patterns and conventions
- Verify assertions against actual behavior — don't guess expected values
- For E2E tests: show me the completed test before running it

## Git

- Never use `git add .` or `git add -A` — stage specific files
- Never use `--no-verify`
- Commit messages: imperative mood, <50 chars, no period

## Recovery

- When stuck or surprised, stop and re-plan. Don't push through confusion
- If something breaks after your change, explain WHAT failed and your THEORY before attempting a fix

## Security

- Never browse ~/.ssh, credential stores, or .env files proactively
- Use existing deployment scripts — they encode connection details safely
- Never include secrets in committed files
- When credentials are needed, ask the user rather than searching for them

## Writing Style

- Use American English
- For headers, use sentence case, not title case
