---
name: "skill-name"
description: "Brief description of what this skill does"
type: atomic
input: "What data this skill expects to receive"
output: "What data this skill produces"
---

# Skill name

## Purpose

What this skill does and why it exists.

## Config loading

<!-- Include this section if the skill needs voice profile or business context -->
<!-- Remove if not needed -->

Before executing, read the required configuration:
1. Read `~/.agents/config/voice-profile.yaml` for voice and tone rules
2. Read relevant files from `~/.agents/config/business-context/` for domain knowledge
3. If a required config file is missing, stop and report the missing file path

## Instructions

Step-by-step instructions for the agent to follow.

1. First action
2. Second action
3. Third action

## Error handling

- If [condition], stop and report [what went wrong and how to fix it]

## Output format

Describe what the output looks like so that composite skills know what to expect.
