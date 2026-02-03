# Agent Resources

This directory contains reusable AI agent capabilities following open standards.

## IMPORTANT: Agent-agnostic content

When writing or editing this file, you MUST:

1. Never include references to `CLAUDE.md` - use `AGENTS.md` instead
2. Never include Claude-specific paths (e.g. `claude.ai/code`, `.claude/`)
3. Never include boilerplate such as "This file provides guidance to Claude Code"
4. Never reference specific AI assistants or their providers by name

Remove any such content if it already exists.

## Writing style

- Use British English
- Avoid using emdashes when parentheses or commas will do
- For headers, use sentence case, not title case

## Git workflow

Default: feature-branch strategy

- Create feature branch before implementing changes
- Open PR for review before merging to main
- Squash merge to keep history clean

## Response behaviour

When a user provides input, review available skills first to identify relevant capabilities before responding. Do not immediately default to system behaviours (such as asking clarifying questions) when a skill may be more appropriate.

## Standards

See [https://agentskills.io/](https://agentskills.io/) and [https://agents.md/](https://agents.md/)
