---
name: curriculum-module
description: "Create a learning module for the platform. Teaches a topic collaboratively, structures it into chapters with steps and questions, then generates upload-ready markdown. Use when the user wants to create curriculum content."
type: composite
depends_on:
  - curriculum-explore
  - curriculum-produce
---

# Curriculum module

## Purpose

Turn a topic into a complete learning module for the Founders and Coders platform. The skill teaches the topic to the user, collaboratively designs the module structure, then generates upload-ready content and UI instructions.

## Steps

### Step 1: Explore and structure the topic
**Skill**: `curriculum-explore`
**Input**: Topic name or description from the user
**Output** → `outline_path`

Read and follow the instructions in `~/.agents/skills/curriculum-module/curriculum-explore.md`.
The result is the path to the saved outline file.

### Step 2: Generate content and instructions
**Skill**: `curriculum-produce`
**Input**: `outline_path` from step 1
**Output** → `none`

Read and follow the instructions in `~/.agents/skills/curriculum-module/curriculum-produce.md`.
Provide the outline path from step 1.

## Output

The user receives:
- A module outline file (YAML, editable)
- Upload-ready markdown files (one per article)
- Step-by-step UI instructions for creating the module in the admin interface
