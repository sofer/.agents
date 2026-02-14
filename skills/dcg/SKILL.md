---
name: dcg
description: Destructive Command Guard - blocks dangerous git and shell commands before execution
source: https://github.com/Dicklesworthstone/destructive_command_guard
---

# DCG (Destructive Command Guard)

A high-performance hook for AI coding agents that blocks destructive commands before they execute, protecting your work from accidental deletion.

## What It Does

Intercepts dangerous commands *before* execution and blocks them with clear explanations:

- **Git commands that destroy uncommitted work:** `git reset --hard`, `git checkout -- .`, `git clean -f`
- **Git commands that destroy remote history:** `git push --force`, `git branch -D`
- **Filesystem commands:** `rm -rf` on paths outside temp directories
- **Heredoc/inline script scanning:** Catches destructive operations embedded in `python -c`, `bash -c`, etc.

## Installation

```bash
curl -fsSL "https://raw.githubusercontent.com/Dicklesworthstone/destructive_command_guard/master/install.sh?$(date +%s)" | bash -s -- --easy-mode
```

## Usage

DCG runs automatically as a hook. When a dangerous command is attempted:

```
════════════════════════════════════════════════════════════════
BLOCKED  dcg
────────────────────────────────────────────────────────────────
Reason:  git reset --hard destroys uncommitted changes

Command: git reset --hard HEAD~5

Tip: Consider using 'git stash' first to save your changes.
════════════════════════════════════════════════════════════════
```

## Configuration

Edit `~/.config/dcg/config.toml` to enable additional protection packs:

```toml
[packs]
enabled = [
    "database.postgresql",    # Blocks DROP TABLE, TRUNCATE
    "kubernetes.kubectl",     # Blocks kubectl delete namespace
    "cloud.aws",              # Blocks aws ec2 terminate-instances
    "containers.docker",      # Blocks docker system prune
]
```

## When to Use

- Always-on protection for AI coding agent sessions
- Pre-commit hooks and CI integration
- Any environment where destructive commands should require explicit confirmation

## References

- [GitHub Repository](https://github.com/Dicklesworthstone/destructive_command_guard)
- [Agent Configuration](https://github.com/Dicklesworthstone/destructive_command_guard/blob/master/docs/agents.md)
