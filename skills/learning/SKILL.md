---
name: learning
description: Append a one-line learning to ~/.agents/learning-log.md. Use when the user types /learning, or when something genuinely worth remembering surfaced during work and the user confirms it should be captured.
---

# Learning

## Purpose

Capture durable lessons without turning every task into memory noise.

## Rules

- Append one line only.
- Capture reusable preferences, tool quirks, non-obvious fixes, workflow improvements, or lessons likely to change future behaviour.
- Do not capture routine progress, trivia, secrets, credentials, private email/calendar content, or anything obvious from the current code.
- If the user invoked `/learning`, treat that as permission to write.
- If the agent noticed a possible learning during normal work, offer the exact candidate learning and wait for confirmation before writing.
- Do not read or summarise the log before appending. It is append-only.

## Format

`YYYY-MM-DDTHH:MM:SS [short-cwd] <learning text>`

Where:
- `short-cwd` is the current working directory relative to `$HOME`, prefixed with `~/`, or `~` if cwd is `$HOME`.
- `<learning text>` is a single grep-friendly sentence.

## Instructions

If the user invoked `/learning` without text, ask once: "What did you learn?"

Append with this command shape:

```bash
printf '%s [%s] %s\n' \
  "$(date +%Y-%m-%dT%H:%M:%S)" \
  "$(pwd | sed "s|^$HOME|~|")" \
  "the learning text" \
  >> "$HOME/.agents/learning-log.md"
```

After appending, briefly confirm what was captured.

