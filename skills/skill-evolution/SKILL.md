---
name: skill-evolution
description: Notice, log, review, and formalise candidate improvements to skills or reusable agent workflows without prematurely editing skills. Use when a conversation reveals repeated workflow friction, a user correction about skill behaviour, or a possible new skill pattern worth preserving for later review.
---

# Skill evolution

Use this skill to notice, log, review, and formalise improvements to existing skills or possible new skills.

## Purpose

The goal is not to create or update skills immediately.

The goal is to preserve useful workflow discoveries while the user is working, so they can be reviewed later and either accepted, rejected, or deferred.

Start with free exploration. Only create or update a skill once a useful pattern has emerged through use.

## When to use

Use this skill when recent conversation suggests:

- the user rejected the current way of working and proposed a better one
- the user corrected how a skill should behave
- the same useful workflow pattern has appeared more than once
- a prompt, checklist, artefact, or process looks reusable
- an existing skill produced friction, latency, ambiguity, or unwanted behaviour
- the user explicitly says something like “next time do it this way”

Do not treat every preference as a skill change. Only log candidates that may improve a reusable workflow.

## Core workflow

1. Observe the recent conversation.
2. Identify possible skill changes or new skill candidates.
3. Log them as pending candidates.
4. Do not edit the skill immediately.
5. Surface candidates for review at a natural checkpoint.
6. Apply only the changes the user accepts.

## Candidate log format

When logging a possible skill change, use this structure:

```json
{
  "type": "skill_update_candidate",
  "skill": "name-of-existing-skill-or-new-skill-candidate",
  "trigger": "What happened in the conversation",
  "evidence": "Short quote or paraphrase from the user",
  "proposed_change": "The possible change to make",
  "reason": "Why this may improve the workflow",
  "status": "pending_review"
}
```

For possible new skills, use:

```json
{
  "type": "new_skill_candidate",
  "candidate_name": "short-descriptive-name",
  "trigger": "What pattern emerged",
  "evidence": "Short quote or paraphrase from the user",
  "possible_scope": "What the skill would help with",
  "reason": "Why this might be worth formalising",
  "status": "pending_review"
}
```

## Review behaviour

At natural checkpoints, summarise pending candidates briefly.

Example:

```text
I noticed two possible skill changes from this session:

1. Update the learning-log hook so it can also log possible skill changes.
2. Add a workflow-discovery pattern: start without a skill, then formalise only after a useful pattern emerges.

Keep, reject, or defer?
```

Do not interrupt deep work just to review candidates unless the user asks.

## Applying changes

Only update an actual skill after the user explicitly accepts the candidate.

When applying an accepted change:

1. Open the existing skill file if there is one.
2. Make the smallest useful edit.
3. Preserve the style and structure of the existing skill.
4. Add a gotcha only if the failure mode is likely to recur.
5. Ask the agent to reread the updated skill before relying on the new behaviour.

## Gotchas

- Do not create a polished skill too early.
- Do not edit skills silently.
- Do not treat a one-off preference as a reusable workflow.
- Do not use this skill to replace judgement; use it to preserve candidate improvements.
- Do not rely on session-end hooks for interactive review; use them only to save state.
- Prefer pending logs over immediate skill edits.
- Prefer small skill updates over large rewrites.
- If a workflow is still exploratory, log it as a candidate rather than formalising it.
