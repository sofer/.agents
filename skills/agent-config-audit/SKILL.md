---
name: agent-config-audit
description: Check whether Claude and Codex have equivalent access to shared agent resources, skills, hooks, plugins, MCP servers, permissions, startup behaviour, and provider-specific adapter config. Use when comparing agent environments, debugging missing capabilities after restart, or deciding whether to symlink a resource or configure a runtime.
---

# Agent config audit

## Purpose

Audit the hub-and-adapters setup for shared agent resources.

Use this rule of thumb:

- Symlink durable file-based resources that agents read.
- Configure provider runtimes for behaviour they own.

## Inspect

Check only what is needed for the question, starting with:

- `~/.agents/AGENTS.md`
- `~/.agents/skills`
- `~/.agents/hooks`
- `~/.agents/docs/provider-compatibility.md`
- `~/.claude/settings.json`
- `~/.claude/settings.local.json`
- `~/.codex/config.toml`
- `~/.codex/config.json`
- relevant plugin metadata under `~/.claude/plugins` or `~/.codex/plugins`

Use `rg`, `find`, `ls -la`, `sed`, and tool help output before opening large logs or caches.

## Classify

Report findings in these buckets:

- `shared and working`: file-based resource is shared and adapter config points to it.
- `shared but unverified`: files or symlinks exist, but active-session behaviour has not been checked.
- `Claude only`: available through Claude config, hooks, plugins, MCP, or permissions only.
- `Codex only`: available through Codex config, hooks, plugins, MCP, or permissions only.
- `missing adapter config`: shared file exists but a runtime is not configured to use it.
- `intentionally provider-specific`: auth, history, cache, plugin cache, session state, or runtime-owned behaviour.
- `unsafe to auto-fix`: change could affect auth, secrets, external systems, permissions, production access, or destructive commands.

## Checklists

For skills:

- Compare `SKILL.md` files under shared skill roots with the active session's available-skill list when available.
- Check whether symlinked skills are top-level directories if discovery appears incomplete.
- Do not assume a filesystem entry means the current session loaded it.

For hooks:

- Distinguish hook scripts from hook registration.
- Verify the script exists, is executable when needed, accepts the runtime's JSON payload shape, and is registered in the provider config.
- Check whether the hook is noisy, blocking, or provider-specific.

For plugins:

- Treat plugin systems as provider-specific unless official metadata and config show portability.
- Do not move plugin caches into `~/.agents`.
- Prefer upstream install/update instructions over copying plugin internals.

For MCP and tools:

- Compare registration and permissions, not just installed files.
- Note provider-specific tool names in skills that may need compatibility sections.

For permissions and safety:

- Compare allow and deny rules separately.
- Flag differences that affect git operations, file edits, web access, external APIs, email, database access, or production systems.

## Fix policy

- Ask before editing `~/.claude`, `~/.codex`, or global `~/.agents` config unless the user explicitly asked for edits.
- Prefer small adapter changes over copying provider-managed files.
- Never move auth, history, cache, plugin cache, session files, or runtime state into `~/.agents`.
- Do not delete provider-specific config unless the user explicitly asks.
- After edits, tell the user whether a full restart is needed or whether clearing/resuming is enough.

## Output

Use this structure:

```markdown
## Summary

<one paragraph>

## Findings

- `<bucket>`: <specific finding with file/config evidence>

## Recommended changes

- <change>, <why>, <whether approval is needed>

## Verification

- <what was checked>
- <what still needs a fresh session or manual confirmation>
```
