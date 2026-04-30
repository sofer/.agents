# Provider compatibility

`~/.agents` is the canonical home for shared instructions, skills, hooks, and local learning logs.

Provider-specific directories remain necessary because each agent runtime owns its own auth, history, plugins, approvals, and hook registration.

## Shared resources

- `AGENTS.md`: shared operating instructions.
- `skills/`: shared personal and third-party skills.
- `hooks/`: shared hook scripts, referenced by provider-specific config.
- `learning-log.md`: local learning notes.
- `skill-usage.log`: local skill usage notes.

## Claude adapter

- `~/.claude/CLAUDE.md` points to `~/.agents/AGENTS.md`.
- `~/.claude/skills` points to `~/.agents/skills`.
- `~/.claude/hooks` points to `~/.agents/hooks`.
- Claude plugins, including Superpowers, remain managed by Claude.

## Codex adapter

- `~/.codex/skills` points to `~/.agents/skills`.
- `~/.agents/skills/superpowers` points to `~/.codex/superpowers/skills`.
- Individual Superpowers skill directories are also exposed as top-level symlinks under `~/.agents/skills` so Codex can discover them as ordinary skills.
- Codex hooks are registered in `~/.codex/config.toml` and point at scripts in `~/.agents/hooks`.
- Codex plugins remain managed by Codex.

## Superpowers

Superpowers is installed separately for each provider.

For Codex, the upstream repo is cloned to `~/.codex/superpowers` and exposed through symlinks in `~/.agents/skills`.

For Claude, Superpowers remains installed as a Claude plugin and starts through Claude's plugin and hook system.

## Limits

- Hook scripts can be shared, but hook registration cannot be fully shared.
- Plugins are provider-specific and should not be moved into `~/.agents`.
- Skills should avoid provider-specific tool names unless the skill is explicitly scoped to one provider.
- If a skill must mention a provider-specific command, isolate that detail in a short compatibility section.
