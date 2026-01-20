# Agent Resources

A cross-platform directory for sharing AI agent capabilities across multiple tools.

## What This Is

This repository contains reusable agent skills that can be shared across different AI coding assistants (Claude Code, GitHub Copilot, Cursor, and others).

## Why This Is Useful

Using the same set of skills and agent instructions across different tools makes it easier to swap between interfaces, either for comparative purposes or to continue working after using up available inference allowances on different platforms.

## File Structure

```
.agents/
├── README.md              # This file (for humans)
├── AGENTS.md              # Project context for AI agents
└── skills/                # Reusable agent capabilities
```

## Setup

To share these skills across different AI tools, create symlinks from each tool's configuration directory:

### For Claude Code

```bash
ln -s ~/.agents/AGENTS.md ~/.claude/CLAUDE.md
ln -s ~/.agents/skills ~/.claude/skills
```

### For Codex CLI

```bash
ln -s ~/.agents/AGENTS.md ~/.codex/AGENTS.md
ln -s ~/.agents/skills ~/.codex/skills
```

### For GitHub Copilot

```bash
ln -s ~/.agents/AGENTS.md ~/.github/AGENTS.md
ln -s ~/.agents/skills ~/.github/skills
```

### For Other Tools

Follow the same pattern for any AI tool that supports these standards:

```bash
ln -s ~/.agents/AGENTS.md ~/.<tool-directory>/AGENTS.md
ln -s ~/.agents/skills ~/.<tool-directory>/skills
```

## Project initialisation

When starting a new project in Claude Code, use the `/init-override` skill instead of `/init`:

```
/init-override
```

This Claude-specific skill:
1. Creates an `AGENTS.md` file in the project root
2. Symlinks `CLAUDE.md` to `AGENTS.md` so Claude Code reads the same file
3. Optionally runs `/init` to auto-discover project settings
4. Sanitises the output to remove Claude-specific references

This allows you to use Claude Code's `/init` feature while keeping project instructions portable across different AI tools.

## Creating skills

Skills follow the [Agent Skills](https://agentskills.io/) open standard.

Note: Some skills in this directory may be personal utilities or tool-specific rather than cross-platform. The `init-override` skill, for example, is Claude-specific but supports the agent-agnostic aims of this repository by sanitising `/init` output.

### Simple Skill (Single File)

Create a `SKILL.md` file directly in the skills directory:

```bash
touch skills/skill-name.md
```

### Expanded Skill (Directory)

Create a skill directory with supporting files:

```bash
mkdir -p skills/skill-name
```

Add a `SKILL.md` file with YAML frontmatter:

```markdown
---
name: skill-name
description: Brief description
---

# Skill Title

## Purpose
What this skill does.

## Instructions
Step-by-step instructions.
```

Add supporting files as needed:
- `scripts/` - Python, Bash, or other executable scripts
- `config.txt` - Configuration files
- `templates/` - Code templates
- `references/` - Reference data

## Open Standards

This repository follows:

- **[Agent Skills](https://agentskills.io/)** - Open format for packaging agent capabilities
- **[AGENTS.md](https://agents.md/)** - Standard for providing project context to AI agents
