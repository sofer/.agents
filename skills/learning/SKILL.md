---
name: learning
description: Append a retrieval-oriented learning entry to ~/.agents/learning-log.md. Use when the user types /learning, or when something genuinely worth remembering surfaced during work and the user confirms it should be captured.
---

# Learning

## Purpose

Capture durable lessons in a form that supports long-term memory through retrieval practice, spaced review, and application, without turning every task into memory noise.

## Rules

- Capture reusable preferences, tool quirks, non-obvious fixes, workflow improvements, or lessons likely to change future behaviour.
- Do not capture routine progress, trivia, secrets, credentials, private email/calendar content, or anything obvious from the current code.
- If the user invoked `/learning`, treat that as permission to write.
- If the agent noticed a possible learning during normal work, offer the exact candidate learning and wait for confirmation before writing.
- Do not read or summarise the log before appending. It is append-only.
- Prefer one atomic lesson per entry.
- Optimise for future recall and application, not polished notes.
- Keep prompts short enough to quiz from later.

## Format

```markdown
## YYYY-MM-DDTHH:MM:SS [short-cwd] <short title>

Lesson: <one atomic lesson>

Why it matters: <practical consequence>

Recall prompt: <question that requires remembering the lesson>

Application prompt: <question that requires applying the lesson in context>

Model answer: <compact answer to both prompts>

Tags: <comma-separated tags>
```

Where:
- `short-cwd` is the current working directory relative to `$HOME`, prefixed with `~/`, or `~` if cwd is `$HOME`.
- `<short title>` is a concise grep-friendly phrase.
- `Lesson` states the durable learning directly.
- `Why it matters` explains the practical consequence in one sentence.
- `Recall prompt` asks for the fact, rule, or distinction.
- `Application prompt` asks when or how to use it.
- `Model answer` gives the intended answer for later self-quizzing.
- `Tags` use stable lowercase terms.

## Instructions

If the user invoked `/learning` without text, ask once: "What did you learn?"

Append with this command shape:

```bash
printf '\n## %s [%s] %s\n\nLesson: %s\n\nWhy it matters: %s\n\nRecall prompt: %s\n\nApplication prompt: %s\n\nModel answer: %s\n\nTags: %s\n' \
  "$(date +%Y-%m-%dT%H:%M:%S)" \
  "$(pwd | sed "s|^$HOME|~|")" \
  "short title" \
  "one atomic lesson" \
  "practical consequence" \
  "recall question" \
  "application question" \
  "compact model answer" \
  "tag-one, tag-two" \
  >> "$HOME/.agents/learning-log.md"
```

After appending, briefly confirm the title and tags captured.
