---
name: init-override
description: Create a symlink from AGENTS.md to CLAUDE.md in the current project directory. Use when the user wants to initialise a project to use AGENTS.md as the memory file instead of CLAUDE.md.
---

# init-override

Create a symlink from AGENTS.md to CLAUDE.md in the current project directory, then optionally run `/init` and sanitise the output.

## Instructions

1. Check if `CLAUDE.md` already exists in the current working directory
   - If it exists and is a symlink pointing to AGENTS.md, inform the user it's already configured and skip to step 4
   - If it exists and is a regular file, warn the user and ask if they want to replace it

2. Create `AGENTS.md` if it doesn't exist, using the template below

3. Create the symlink: `ln -s AGENTS.md CLAUDE.md`

4. Ask the user if they want to run `/init` to auto-discover project settings
   - If yes, run `/init` and then proceed to step 5
   - If no, confirm success and finish

5. Sanitise the AGENTS.md file by removing or replacing:
   - Any line containing "Claude Code" or "claude.ai"
   - References to `CLAUDE.md` (replace with `AGENTS.md`)
   - References to `.claude/` paths
   - The boilerplate phrase "This file provides guidance to Claude Code"
   - Replace "Claude" with "AI agents" where it refers to the assistant

6. Ensure the file header is `# AGENTS.md` (not `# CLAUDE.md` or `# Project guidance`)

7. Confirm success and show the user the sanitised content

## AGENTS.md template

Use this content when creating a new AGENTS.md file (before `/init` runs):

```markdown
# AGENTS.md

This file provides guidance for AI agents working with code in this repository.
```
