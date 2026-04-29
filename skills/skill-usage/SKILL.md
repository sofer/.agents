---
name: skill-usage
description: Record substantive skill use in an append-only local log. Use after choosing or invoking a non-system skill for real work, when a skill is inspected but not used, or when a skill fails to apply. Do not use for routine system skills or incidental file reads.
type: atomic
input: "Skill name, mode (used, inspected, failed), trigger (explicit, implicit, composite, manual), and a brief non-sensitive purpose"
output: "One appended line in ~/.agents/skill-usage.log"
---

# Skill usage

## Purpose

Track which personal skills are actually being used so the user can prune, improve, or keep skills based on evidence.

## Rules

- Log only substantive personal skill activity.
- Do not log routine system skills, incidental file reads, or skill-review work unless the user asks to audit skill usage.
- Never log sensitive content from emails, calendar events, database rows, credentials, personal data, or user-private task details.
- Keep the purpose short and generic enough to be safe in a local audit log.
- Append only. Do not rewrite or summarise the log unless the user explicitly asks.

## Fields

- `timestamp`: local ISO-like timestamp, second precision.
- `cwd`: current working directory with `$HOME` shortened to `~`.
- `skill`: skill name.
- `mode`: `used`, `inspected`, or `failed`.
- `trigger`: `explicit`, `implicit`, `composite`, or `manual`.
- `purpose`: short non-sensitive reason.

## Instructions

1. Identify the skill activity to record.
2. Classify the mode:
   - `used`: the skill guided substantive work.
   - `inspected`: the skill was opened to assess applicability but not used.
   - `failed`: the skill should have applied but could not be used.
3. Classify the trigger:
   - `explicit`: the user named the skill or requested that capability directly.
   - `implicit`: the agent selected the skill from the request.
   - `composite`: another skill invoked it as a step.
   - `manual`: the user asked to record usage.
4. Write one line to `~/.agents/skill-usage.log`.

Use this command shape:

```bash
printf '%s [%s] skill=%s mode=%s trigger=%s purpose=%q\n' \
  "$(date +%Y-%m-%dT%H:%M:%S)" \
  "$(pwd | sed "s|^$HOME|~|")" \
  "skill-name" \
  "used" \
  "implicit" \
  "brief non-sensitive purpose" \
  >> "$HOME/.agents/skill-usage.log"
```

## Output format

After appending, briefly report the line that was recorded, unless the skill was invoked silently from an approved workflow.

