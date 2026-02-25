---
name: "twin-name"
description: "Brief description of what this composite skill does"
type: composite
depends_on:
  - first-skill
  - second-skill
  - third-skill
---

# Twin name

## Purpose

What this composite skill does and why it exists.

## Config loading

<!-- Include this section if any steps need voice profile or business context -->
<!-- Remove if not needed -->

Before starting the steps below:
1. Read `~/.agents/config/voice-profile.yaml` for voice and tone rules
2. Read relevant files from `~/.agents/config/business-context/` for domain knowledge
3. If any required config is missing, stop and report the expected path

## Steps

### Step 1: Description of first step
**Skill**: `first-skill`
**Input**: Where the data comes from (user request, config, or prior step output)
**Output** → `result_one`

Read and follow the instructions in `~/.agents/skills/first-skill/SKILL.md`.
Provide the input described above. The result is referred to as `result_one` in subsequent steps.

### Step 2: Description of second step
**Skill**: `second-skill`
**Input**: Data from `result_one` and/or other sources
**Output** → `result_two`

Read and follow the instructions in `~/.agents/skills/second-skill/SKILL.md`.

### Step 3: Description of third step
**Skill**: `third-skill`
**Input**: Data from `result_one` and `result_two`
**Output** → `final_result`

Read and follow the instructions in `~/.agents/skills/third-skill/SKILL.md`.

## Output

Describe what the user sees when this composite skill completes.
