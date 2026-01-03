# Agent Resources

A cross-platform directory for sharing AI agent capabilities across multiple tools.

## What This Is

This repository contains reusable agent skills that can be shared across different AI coding assistants (Claude Code, GitHub Copilot, Cursor, and others).

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
ln -s ~/.agents/AGENTS.md ~/.claude/AGENTS.md
ln -s ~/.agents/skills ~/.claude/skills
```

### For GitHub Copilot / Codex

```bash
ln -s ~/.agents/AGENTS.md ~/.codex/AGENTS.md
ln -s ~/.agents/skills ~/.codex/skills
```

### For Other Tools

Follow the same pattern for any AI tool that supports these standards:

```bash
ln -s ~/.agents/AGENTS.md ~/.<tool-directory>/AGENTS.md
ln -s ~/.agents/skills ~/.<tool-directory>/skills
```

## Creating Skills

Skills follow the [Agent Skills](https://agentskills.io/) open standard.

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
