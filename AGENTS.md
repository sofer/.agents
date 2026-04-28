# Agent Resources

This directory contains reusable AI agent capabilities following open standards.

## IMPORTANT: Agent-agnostic content

When writing or editing this file, you MUST:

1. Never include references to `CLAUDE.md` - use `AGENTS.md` instead
2. Never include Claude-specific paths (e.g. `claude.ai/code`, `.claude/`)
3. Never include boilerplate such as "This file provides guidance to Claude Code"
4. Never reference specific AI assistants or their providers by name

Remove any such content if it already exists.

**Keep entries in this file to one line each. If a rule needs explanation, put it in a skill or a linked doc.**

## Writing style

- Use British English
- Never use em dashes. Use commas, parentheses, full stops, or colons instead
- For headers, use sentence case, not title case

## Development

- Red/Green/Refactor TDD
- For any feature involving user registration, email, authentication links, or multi-step user flows: use the `end-to-end-verification` skill before pushing. Test the complete chain with a real email address.
- Skills that should fire automatically get a hook-install hint at the end of the body (not the description). Use `/update-config` to wire.

## Git workflow

- Check the repo's AGENTS.md for the commit strategy before starting work. Never push changes directly to main unless the repo's AGENTS.md explicitly permits it, or the user expressly requests it for this task. When in doubt, ask before pushing.
- Never add Co-Authored-By or attribution footers to commit messages
- Never add AI tool attribution lines to PR descriptions (e.g. "Generated with...")

## Response behaviour

When a user provides input, review available skills first to identify relevant capabilities before responding. Do not immediately default to system behaviours (such as asking clarifying questions) when a skill may be more appropriate.

## Agent resources directory

`~/.agents/` contains shared agent configuration:

- `hooks/pre-commit-review.sh` — pre-commit code review hook (symlinked into the agent's global hooks directory)

## Standards

See [https://agentskills.io/](https://agentskills.io/) and [https://agents.md/](https://agents.md/)
